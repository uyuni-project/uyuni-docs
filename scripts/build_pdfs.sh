#!/usr/bin/env bash
# Build all the language x book PDFs for one product, concurrently.
#
# asciidoctor-pdf runs on one core. Concurrent books are therefore the only way
# to make this build use more than one core.
#
# Usage: build_pdfs.sh <product> "<languages>" "<books>"
# JOBS caps the number of concurrent books. The default is the core count.
#
# The caller stages each language first with 'task pdf-stage'. Every book of a
# language shares one content tree and one entities.adoc, and concurrent writes
# to them are not safe. The 'pdf' task refuses to build if the caller did not
# stage, therefore this script does not check.

set -u

if [ $# -ne 3 ] ; then
    echo "usage: $0 <product> \"<languages>\" \"<books>\"" >&2
    exit 2
fi

PRODUCT="$1"
LANGUAGES="$2"
BOOKS="$3"

# An empty list builds no PDFs. Without this check, the script prints a summary
# and exits 0, and the publish steps then package an empty tree.
if [ -z "${LANGUAGES// /}" ] || [ -z "${BOOKS// /}" ] ; then
    echo "$0: LANGUAGES and BOOKS must both be non-empty (got '${LANGUAGES}' and '${BOOKS}')" >&2
    exit 2
fi

# flock keeps the logs of concurrent books separate. Without flock, the output
# of a failed build mixes with the output of the other books.
if ! command -v flock >/dev/null 2>&1 ; then
    echo "$0: flock is required (package util-linux)." >&2
    exit 2
fi

# Read the cgroup CPU quota first. nproc reports the CPU affinity mask and not
# the quota, so a container with a --cpus limit sees all the cores of the host.
# One asciidoctor-pdf for each host core uses all the memory of a small runner,
# and the OOM kill shows only as exit 137.
if [ -z "${JOBS:-}" ] ; then
    JOBS=$(nproc 2>/dev/null || echo 4)
    if [ -r /sys/fs/cgroup/cpu.max ] ; then
        read -r quota period < /sys/fs/cgroup/cpu.max || true
        if [ "${quota:-max}" != "max" ] && [ "${period:-0}" -gt 0 ] ; then
            cpus=$(( (quota + period - 1) / period ))
            [ "${cpus}" -lt 1 ] && cpus=1
            [ "${cpus}" -lt "${JOBS}" ] && JOBS=${cpus}
        fi
    fi
fi

# 'xargs -P 0' is unlimited concurrency, thus reject every spelling of zero and
# not only the one digit. '00' passes a '0' test and gives one asciidoctor-pdf
# for each book of each language at the same time.
case "${JOBS}" in
    ''|*[!0-9]*|0|0[0-9]*)
        echo "$0: JOBS must be a positive integer, got '${JOBS}'" >&2
        exit 2
        ;;
esac

WORKDIR=$(mktemp -d) || { echo "$0: mktemp -d failed; set TMPDIR to a writable directory." >&2; exit 1; }
if [ ! -d "${WORKDIR}" ] ; then
    echo "$0: mktemp -d returned no usable directory." >&2
    exit 1
fi
trap 'rm -rf "${WORKDIR}"' EXIT
: > "${WORKDIR}/lock" || exit 1

export WORKDIR PRODUCT

# Build one book. Each job writes to its own log and prints it under a lock.
# Concurrent books therefore do not mix their output.
build_one() {
    # xargs starts a new shell, and a new shell does not inherit shell options.
    # Without 'set -u', a short input line makes book or lang an empty string.
    # 'task pdf' then builds the default book or no language, and exits 0.
    set -u
    local book="${1:?build_one: no book}"
    local lang="${2:?build_one: no lang}"
    local log="${WORKDIR}/${lang}-${book}.log"
    local rc

    # STAGE=0: the caller stages the shared files of this language. A second
    # staging operation from each book is not safe.
    task pdf BOOK="${book}" PRODUCT="${PRODUCT}" LANGUAGES="${lang}" STAGE=0 > "${log}" 2>&1
    rc=$?

    # A failed redirect skips the full group. Print the log without the lock, or
    # you lose it. The log is the only record of the failure.
    if ! {
        flock 9
        cat "${log}"
        if [ ${rc} -ne 0 ] ; then
            # The same stream as the log, therefore the two stay together.
            echo "==> FAILED: ${PRODUCT} / ${lang} / ${book} (exit ${rc})"
        fi
    } 9< "${WORKDIR}/lock"
    then
        echo "==> ${PRODUCT} / ${lang} / ${book}: cannot lock ${WORKDIR}/lock; output follows unserialized" >&2
        cat "${log}" >&2
        [ ${rc} -eq 0 ] || echo "==> FAILED: ${PRODUCT} / ${lang} / ${book} (exit ${rc})" >&2
    fi

    rm -f "${log}"
    return ${rc}
}
export -f build_one

echo "==> ${PRODUCT} PDFs — languages: ${LANGUAGES} — ${JOBS} at a time"

for lang in ${LANGUAGES}; do
    for book in ${BOOKS}; do
        printf '%s %s\n' "${book}" "${lang}"
    done
done | xargs -r -P "${JOBS}" -L 1 bash -c 'build_one "$1" "$2"' bash
rc=$?

# All non-zero statuses are failures, but they have different causes. Only 123
# tells you that the other books completed.
case ${rc} in
    0)
        ;;
    123)
        echo "==> One or more ${PRODUCT} PDFs failed to build. See the FAILED lines above." >&2
        exit 1
        ;;
    124)
        echo "==> ${PRODUCT} build stopped: a book exited 255, and xargs did not start the books that remained." >&2
        exit 1
        ;;
    125)
        echo "==> ${PRODUCT} build stopped: a signal killed a book. Out of memory, or interrupted." >&2
        exit 1
        ;;
    126|127)
        echo "==> ${PRODUCT} build did not start: xargs cannot run bash or import build_one (exit ${rc}). The build made no PDFs." >&2
        exit 1
        ;;
    *)
        echo "==> ${PRODUCT} build failed: unexpected xargs exit ${rc}." >&2
        exit 1
        ;;
esac
