#!/bin/bash
set -o errexit

for DIR in ../l10n/pot/* ; do
	if ! test -d "$DIR" ; then
		continue
	fi
	DOMAIN=${DIR##*/}
	echo "$DOMAIN/$DOMAIN.pot"
	mkdir -p "$DOMAIN"
	msgcat --use-first `find "$DIR" -name "*.pot"` -o "$DOMAIN/$DOMAIN".pot
	for LNGDIR in ../l10n/po/*/"$DOMAIN" ; do
		if ! test -d "$LNGDIR" ; then
			continue
		fi
		LNG=${LNGDIR%/*}
		LNG=${LNG##*/}
		echo "$DOMAIN/$LNG.po"
		# In case of conflict, weblate translation takes precedence.
		# Better would be --use-newest, which is not in the upstream yet.
		if test -f "$DOMAIN/$LNG".po ; then
			msgcat --use-first "$DOMAIN/$LNG".po `find ../l10n/po/$LNG/$DOMAIN -name "*.po"` -o "$DOMAIN/$LNG".po.new
		else
			msgcat --use-first `find ../l10n/po/$LNG/$DOMAIN -name "*.po"` -o "$DOMAIN/$LNG".po.new
		fi
		mv "$DOMAIN/$LNG".po.new "$DOMAIN/$LNG".po
	done
done
