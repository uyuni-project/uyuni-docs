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

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

SRCDIR_MODULE="./modules"

# place where the po files are
if [ -z "$PO_DIR" ] ; then
	PO_DIR="./l10n-weblate/"
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


#######################################################################
# GENERATE TRANSLATED ASCIIDOC FROM .PO FILES, WITHOUT UPDATING .POT/PO
#######################################################################

for f in $(ls $CURRENT_DIR/$PO_DIR/*.cfg); do
    po4a --srcdir $CURRENT_DIR --destdir $CURRENT_DIR -k 0 -M utf-8 -L utf-8 --no-update $f
done



############################################################
# COPY LOCALIZED SCREENSHOTS TO LOCALIZED ASCIIDOC DIRECTORY
############################################################

for module in $(find $CURRENT_DIR/$PO_DIR -mindepth 1 -maxdepth 1 -type d -printf "%f\n"); do
    for langpo in $(find $CURRENT_DIR/$PO_DIR/$module -mindepth 1 -maxdepth 1 -type f -name "*.po" -printf "%f\n"); do
        lang=`basename $langpo .po`
        if [ -e $CURRENT_DIR/$PO_DIR/$module/assets-$lang ]; then
            mkdir -p $CURRENT_DIR/$PUB_DIR/$lang/modules/$module/assets/images && \
            cp -a $CURRENT_DIR/$PO_DIR/$module/assets-$lang/* $CURRENT_DIR/$PUB_DIR/$lang/modules/$module/assets/
        fi
    done
done
