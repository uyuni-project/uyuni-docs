#!/bin/bash

usage() {
# `cat << EOF` This means that cat should stop reading when EOF is detected
cat << EOF  
Usage: ./ifeval_routine [-cfh]
Every ifeval tag requires above a blank line, otherwise translations will be corrupted.
This tool is used for checking of fixing all adoc files
-h, --help                  Display help
-c, --check                 Check all adoc files. Return number of lines where there's an error
-f, --fix                   Fix all adoc files.
EOF
# EOF is found above and hence cat command stops reading. This is equivalent to echo but much neater when printing out.
}


options=$(getopt -l "help,check,fix" -o "hcf" -a -- "$@")

export CHECK=0
export FIX=0
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
-c|--check) 
    export CHECK=1
    ;;
-f|--fix)
    export FIX=1
    ;;
--)
    shift
    break;;
esac
shift
done

if [ $CHECK == 1 ]; then
    IF_EVAL_CORRECT=$(find -name "*\.adoc" -type f -print0 | xargs -0 grep -nr "^\s*$*ifeval" | wc -l)
    IF_EVAL=$(find -name "*\.adoc" -type f -print0 | xargs -0 grep -nr "ifeval" | wc -l)
    RES=$(($IF_EVAL-$IF_EVAL_CORRECT))
    echo "Total number of errors: $RES"
    exit $RES
fi

if [ $FIX == 1 ]; then
    find -name "*\.adoc" -type f -print0 | xargs -0 sed -i 's/^$ifeval::/\nifeval::/g'
    exit 0
fi

exit 0
