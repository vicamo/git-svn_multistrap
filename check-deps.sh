#!/bin/sh
set -e

#  Copyright 2010 Neil Williams <codehelp@debian.org>
#  Copyright 2010 Philip Hands <phil@hands.com>

#  This package is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# using the package directly means we don't have to deal
# with multiline Depends

while [ -n "$1" ]; do
case "$1" in
	-\?|-h|--help)
		shift
		echo "-f path to a .deb filename; -i install the packages now."
		exit 0
	;;
	-f|--file)
		shift
		FILE=$1
		shift
	;;
	-i|--install)
		shift
		INSTALL=1
	;;
	*)
		echo "Unrecognised option: $1"
	exit;
	;;
esac
done

if [ ! -f "$FILE" -o ! -r "$FILE" ]; then
	echo "Please specify a path to a debian package file with the -f command."
	exit 2
fi

DEPS=$(dpkg-deb -f $FILE Depends) || exit 3
IFS=,
CMD=
ERR=
for pkg in $DEPS; do
	CHECK=
	name=$(echo $pkg|sed -e 's/^ //'|cut -d' ' -f1)
	if [ "apt" = "$name" ]; then
		continue
	fi
	if [ -n `echo $pkg|grep '('` ]; then
		VERLIMIT=`echo $pkg|cut -d'(' -f2|tr -d ')'|tr -d '\n'|grep -v $name || true`
		VERCMP=`echo $VERLIMIT|sed -e 's/\(.*\) \(.*\)/\1/'`
		VERLIMIT=`echo $VERLIMIT|sed -e 's/\(.*\) \(.*\)/\2/'`
	fi
	POLICY=`LC_ALL=C apt-cache policy $name 2>/dev/null|grep Candidate|cut -d':' -f2-3|tr -d ' '`
	if [ -n "$POLICY" ]; then
		if [ -n "$VERLIMIT" ]; then
			CHECK=`dpkg --compare-versions $POLICY "$VERCMP" $VERLIMIT ; echo $?`
		fi
	else
		ERR="$ERR $name "
	fi
	if [ -z "$CHECK" -o "0" != "$CHECK" ]; then
		if [ -n "$VERCMP" ]; then
			echo "$name ($VERCMP $VERLIMIT) is NOT available."
			ERR="$ERR $name ($VERCMP $VERLIMIT) "
		fi
	fi
	CMD="$CMD $name"
done
if [ -n "$ERR" ]; then
	echo Some packages are not available: $ERR
	exit 1
fi
if [ -n "$INSTALL" ]; then
	eval apt-get install "$CMD"
	dpkg -i $FILE
else
	echo apt-get install $CMD
fi
