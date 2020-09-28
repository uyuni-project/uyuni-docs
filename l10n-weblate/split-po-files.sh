#!/bin/bash
set -o errexit

for DIR in * ; do
	if ! test -d "$DIR" ; then
		continue
	fi
	for WLPO in $DIR/*.po ; do
		# basename
		LNG=${WLPO##*/}
		LNG=${LNG%.po}
		for POT in `find ../l10n/pot/$DIR -name "*.pot"` ; do
			# Replce string pot by $LNG/po
			ADPO=${POT/pot/po/$LNG}
			# .pot => .po
			ADPO=${ADPO%t}
			ADPODIR=${ADPO%/*}
			mkdir -p "$ADPODIR"
			echo -n "${ADPO#../}"
			msgmerge --force-po --no-fuzzy-matching "$WLPO" "$POT" -o "$ADPO".tmp1
			msgattrib --force-po --no-obsolete "$ADPO".tmp1 -o "$ADPO".tmp2
			if test -f "$ADPO" ; then
				# In case of conflict, weblate translation takes precedence.
				# Better would be --use-newest, which is not in the upstream yet.
				msgcat --force-po --use-first "$ADPO".tmp2 "$ADPO" -o "$ADPO"
			else
				mv "$ADPO".tmp2 "$ADPO"
			fi
			rm "$ADPO".tmp*
		done
	done
done
