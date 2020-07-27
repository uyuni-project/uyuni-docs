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
	PO_DIR="./l10n/po"
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


####################################
# DEFINE ANTORA MODULES (adoc files)
####################################

use_po_module () {
	lang=$1

    for module in $(ls $PO_DIR/$lang); do
        if [ -e $PO_DIR/$lang/$module/assets/images ]; then
            mkdir -p $PUB_DIR/$lang/modules/$module/assets/images
            cp -a $PO_DIR/$lang/$module/assets/* $PUB_DIR/$lang/modules/$module/assets/
        fi
    done


	while IFS= read -r -d '' file
	do
		basename=$(basename -s .adoc "$file")
		dirname=$(dirname "$file")
		path="${dirname#$SRCDIR_MODULE/}"

		if [ "$dirname" = "$SRCDIR_MODULE" ]; then
			potname=$basename
			localized_file="$PUB_DIR/$lang/modules/$basename.adoc"
		else
			potname=$path/$basename
			localized_file="$PUB_DIR/$lang/modules/$path/$basename.adoc"
		fi

		if [ ! -e "$PO_DIR/$lang/$potname.po" ]; then
			po4a-gettextize \
				--format asciidoc \
				--master "$file" \
				--master-charset "UTF-8" \
				--po "$PO_DIR/$lang/$potname.po"
		fi

		po4a-translate \
			--format asciidoc \
			--master "$file" \
			--master-charset "UTF-8" \
			--po "$PO_DIR/$lang/$potname.po" \
			--localized "$localized_file" --localized-charset "UTF-8" \
			--keep 0
	done <   <(find -L "$SRCDIR_MODULE" -name "*.adoc"  -print0)
}

####################################
# HANDLE ANTORA MODULES (adoc files)
####################################

while IFS= read -r -d '' dir
do
	lang=$(basename -s .adoc "$dir")
	use_po_module "$lang"
done <   <(find "$PO_DIR" -mindepth 1 -maxdepth 1 -type d -print0)
