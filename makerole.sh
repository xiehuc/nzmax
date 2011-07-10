#!/bin/bash

if [ ! $1 ] ;then
    echo "Usage: makerole.sh <dirname>"
    exit
fi

cd $1
for gif in *.gif
do
    swf=$(basename "$gif" .gif).swf
    gif2swf -r24 -o "_$swf" $gif
    swfcombine -r24 -to $swf "_$swf"
    rm "_$swf"
done
ori=$(find . -iname "*.swf")
#dst=""
#for item in $ori
#do
#dst+="$(basename $item .swf)=$item "
#done
swfcombine -F11 -r24 -NBazo ../$1.swf $ori
cd ..
if [ ! -e $1.xml ]
then
    echo '<?xml version="1.0" encoding="utf-8" ?>' >$1.xml
    echo "
<role>
    <path>$1.swf</path>
    <name></name>
    <engname>$1</engname>
    <sex></sex>
    <version>0.9</version>
    <!--">>$1.xml
    i=0
    for item in $ori
    do
        i=`expr $i + 1`
        echo "$item   $i" >>$1.xml
    done
    echo "-->
</role>" >>$1.xml
fi

