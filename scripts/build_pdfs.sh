#!/usr/bin/env bash
# Build all the language x book PDFs for one product, more than one at a time.
#
# asciidoctor-pdf has one thread. Concurrent books are therefore the only way
# to make this build use more than one core.
#
# Usage: build_pdfs.sh <product> "<languages>" "<books>"
# JOBS caps the number of concurrent books. The default is nproc.
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

if [ -z "${JOBS:-}" ] ; then
    JOBS=$(nproc 2>/dev/null || echo 4)
fi

case "${JOBS}" in
    ''|*[!0-9]*|0)
        echo "usage: JOBS must be a positive integer, got '${JOBS}'" >&2
        exit 2
        ;;
esac

WORKDIR=$(mktemp -d)
trap 'rm -rf "${WORKDIR}"' EXIT
: > "${WORKDIR}/lock"

export WORKDIR PRODUCT

# Build one book. Each job writes to its own log and prints it under a lock.
# Concurrent books therefore do not mix their output.
build_one() {
    local book="$1"
    local lang="$2"
    local log="${WORKDIR}/${lang}-${book}.log"
    local rc

    # STAGE=0: the shared files for this language are in place (see below).
    # A second staging operation from each book is not safe.
    task pdf BOOK="${book}" PRODUCT="${PRODUCT}" LANGUAGES="${lang}" STAGE=0 > "${log}" 2>&1
    rc=$?

    {
        flock 9
        cat "${log}"
        if [ ${rc} -ne 0 ] ; then
            # The same stream as the log, therefore the two stay together.
            echo "==> FAILED: ${PRODUCT} / ${lang} / ${book} (exit ${rc})"
        fi
    } 9< "${WORKDIR}/lock"

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

# xargs returns 123 if an invocation failed. Report a plain failure.
if [ ${rc} -ne 0 ] ; then
    echo "==> One or more ${PRODUCT} PDFs failed to build." >&2
    exit 1
fi
