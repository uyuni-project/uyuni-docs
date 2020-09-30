#!/bin/bash
# You need po4a > 0.58, see https://github.com/mquinson/po4a/releases
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
	PO_DIR="./l10n-weblate/"
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
# COPY ENGLISH SCREENSHOTS TO EACH LANGUAGE
####################################

for module in $(ls "$PO_DIR" ); do
    for langpo in $(cd "$PO_DIR/$module" && ls *.po); do
        if [ -e modules/$module/assets/images ]; then
            lang=`basename $langpo .po`
            rsync -u --inplace -a --delete modules/$module/assets/* $PO_DIR/$module/assets-$lang/
        fi
    done
done
