#!/bin/sh
NLINES=0
for f in *.k
do
	echo "Counting lines in $f file..."
	NLINES=$(($NLINES + $(kpp $f | wc -l)))
done

echo $NLINES