#!/bin/bash

usage() {
# `cat << EOF` This means that cat should stop reading when EOF is detected
cat << EOF  
Usage: ./ifeval_routine [-cfh]
Custom checkstyle for adoc files
This tool is used for checking all adoc files
-h, --help                  Display help
-c, --comment_nav_file      Check if nav files contains comment
-i, --ifeval                Check if every ifeval tag requires has an blank line, otherwise translations will be corrupted.

EOF
# EOF is found above and hence cat command stops reading. This is equivalent to echo but much neater when printing out.
}


options=$(getopt -l "help," -o "hic" -a -- "$@")

export IFEVAL=0
export NAV_COMMENT=0
eval set -- "$options"

if [ $# -eq 1 ]; then
    usage
    exit 0
fi

while true
do
case $1 in
-h|--help) 
    usage
    exit 0
    ;;
-i|--ifeval) 
    export IFEVAL=1
    ;;
-c|--comment_nav_file) 
    export NAV_COMMENT=1
    ;;
--)
    shift
    break;;
esac
shift
done

if [ $IFEVAL == 1 ]; then
    IF_EVAL_CORRECT_COUNT=$(find -name "*\.adoc" -type f -print0 | xargs -0 grep -hrB1 '^ifeval' | grep '^[[:blank:]]*$'| wc -l)
    IF_EVAL_COUNT=$(find -name "*\.adoc" -type f -print0 | xargs -0 grep -nr "^ifeval" | wc -l)
    IFEVAL_WITHOUT_NEWLINES_COUNT=$(($IF_EVAL_COUNT-$IF_EVAL_CORRECT_COUNT))
    echo "Total number of ifevals without a prior newline: $IFEVAL_WITHOUT_NEWLINES_COUNT"
    exit $IFEVAL_WITHOUT_NEWLINES_COUNT
fi

if [ $NAV_COMMENT == 1 ]; then
    NAV_COMMENT_COUNT=$(find modules -name "nav*\.adoc" -type f -print0 | xargs -0 grep '^//' | grep -v '// NO COMMENTS ALLOWED IN NAV LIST FILES EXCEPT THIS ONE!' | wc -l)
    echo "Total number of comments if nav file: $NAV_COMMENT_COUNT"
    exit $NAV_COMMENT_COUNT
fi

exit 0
