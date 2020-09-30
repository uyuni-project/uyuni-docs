#!/bin/bash
# You need po4a > 0.54, see https://github.com/mquinson/po4a/releases
# There is no need of system-wide installation of po4a
# Usage: PERLLIB=/path/to/po4a/lib use_po.sh
# you may set following variables
# SRCDIR root of the documentation repository
# PODIR place where to create the po
# PUB_DIR place where to publish localized files

####################################
# INITILIZE VARIABLES
####################################

SRCDIR_MODULE="./modules"

# place where the po files are
if [ -z "$PO_DIR" ] ; then
	PO_DIR="./l10n-po4a"
fi

# place where the localized files will be
if [ -z "$PUB_DIR" ] ; then
	PUB_DIR="./translations/"
fi


####################################
# TEST IF IT CAN WORK
####################################

if [ ! -d "$SRCDIR_MODULE" ] ; then
	echo "Please run this script from the documentation' root folder"
	exit 1
fi


############################################################
# COPY LOCALIZED SCREENSHOTS TO LOCALIZED ASCIIDOC DIRECTORY
############################################################

for module in $(ls "$PO_DIR" ); do
    for langpo in $(cd "$PO_DIR/$module" && ls *.po); do
        lang=`basename $langpo .po`
        if [ -e $PO_DIR/$module/assets-$lang ]; then
            mkdir -p $PUB_DIR/$lang/modules/$module/assets/images
            cp -a $PO_DIR/$module/assets-$lang/* $PUB_DIR/$lang/modules/$module/assets/
        fi
    done
done
