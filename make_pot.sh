#!/bin/bash
# You need po4a > 0.54, see https://github.com/mquinson/po4a/releases
# There is no need of system-wide installation of po4a
# Usage: PERLLIB=/path/to/po4a/lib make_pot.sh
# you may set following variables
# SRCDIR root of the documentation repository
# POTDIR place where to create the pot

####################################
# INITILIZE VARIABLES
####################################

# root of the documentation repository
SRCDIR_MODULE="./modules"

# place where to create the pot files
if [ -z "$POTDIR" ] ; then
    POTDIR="./l10n/pot/"
fi

# place where the po files are
if [ -z "$PO_DIR" ] ; then
	PO_DIR="./l10n/po/"
fi

####################################
# TEST IF IT CAN WORK
####################################

if [ ! -d "$SRCDIR_MODULE" ] ; then
    echo "Error, please check that SRCDIR match to the root of the documentation repository"
    echo "You specified modules are in $SRCDIR_MODULE"
    exit 1
fi


####################################
# HANDLE articles and pages
####################################

while IFS= read -r -d '' file
do
    basename=$(basename -s .adoc "$file")
    dirname=$(dirname "$file")
    path="${dirname#$SRCDIR_MODULE/}"

    if [ "$dirname" = "$SRCDIR_MODULE" ]; then
        potname=$basename.pot
    else
        potname=$path/$basename.pot
        mkdir -p "$POTDIR/$path"
    fi

    po4a-gettextize \
        --format asciidoc \
        --master "$file" \
        --master-charset "UTF-8" \
        --po "$POTDIR/$potname"

    for lang in $(ls "$PO_DIR" ); do

        po_file="$PO_DIR/$lang/${potname%.pot}.po"

        # po4a-updatepo would be angry otherwise
        sed -i 's/Content-Type: text\/plain; charset=CHARSET/Content-Type: text\/plain; charset=UTF-8/g' "$po_file"

        if ! po4a-updatepo \
            --format asciidoc \
            --master "$file" \
            --master-charset "UTF-8" \
            --po "$po_file" ; then
        echo ""
        echo "Error updating $lang PO file $po_file for: $adoc_file"

        fi
    done

done <   <(find -L "$SRCDIR_MODULE" -name "*.adoc" -print0)

echo ""
echo "#REMOVE TEMPORARY FILES"

for lang in $(ls "$PO_DIR" ); do
    for module in $(ls modules); do
        if [ -e modules/$module/assets/images ]; then
            mkdir -p $PO_DIR/$lang/$module/assets/images
            rsync -u --inplace -a --delete modules/$module/assets/* $PO_DIR/$lang/$module/assets/
        fi
    done
    
	rm -f "l10n/po/$lang/contact/"*.po~
	rm -f "l10n/po/$lang/articles/"*.po~
done
