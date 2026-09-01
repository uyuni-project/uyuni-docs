#!/usr/bin/env bash
# Build every language x book PDF for one product, several at a time.
#
# asciidoctor-pdf is single-threaded, so the only thing that scales this build
# is running books concurrently: the full 32-PDF MLM matrix takes ~5 minutes
# one at a time and well under a minute spread across a desktop's cores.
#
# Usage: build_pdfs.sh <product> "<languages>" "<books>"
# Set JOBS to cap concurrency; it defaults to nproc.

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

# Build one book. Output goes to a per-job log that is flushed under a lock, so
# concurrent books do not interleave their output and a failing book stays
# identifiable in the noise.
build_one() {
    local book="$1"
    local lang="$2"
    local log="${WORKDIR}/${lang}-${book}.log"
    local rc

    # STAGE=0: the shared per-language files are already in place (see below),
    # and staging them again from every book would race.
    task pdf BOOK="${book}" PRODUCT="${PRODUCT}" LANGUAGES="${lang}" STAGE=0 > "${log}" 2>&1
    rc=$?

    {
        flock 9
        cat "${log}"
        if [ ${rc} -ne 0 ] ; then
            # Same stream as the log above, so the two stay together.
            echo "==> FAILED: ${PRODUCT} / ${lang} / ${book} (exit ${rc})"
        fi
    } 9< "${WORKDIR}/lock"

    rm -f "${log}"
    return ${rc}
}
export -f build_one

echo "==> ${PRODUCT} PDFs — languages: ${LANGUAGES} — ${JOBS} at a time"

# Stage every language once, before any book starts. Doing this per book would
# have every book of a language copy the same tree and rewrite the same
# entities.adoc at the same time.
task pdf-stage PRODUCT="${PRODUCT}" LANGUAGES="${LANGUAGES}" || exit 1

for lang in ${LANGUAGES}; do
    for book in ${BOOKS}; do
        printf '%s %s\n' "${book}" "${lang}"
    done
done | xargs -r -P "${JOBS}" -L 1 bash -c 'build_one "$1" "$2"' bash
rc=$?

# xargs reports 123 when any invocation failed; normalise to a plain failure.
if [ ${rc} -ne 0 ] ; then
    echo "==> One or more ${PRODUCT} PDFs failed to build." >&2
    exit 1
fi
