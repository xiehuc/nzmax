#!/bin/bash
cd $1
for gif in *.gif
do
    swf=$(basename "$gif" .gif).swf
    gif2swf -o "_$swf" $gif
    swfcombine -to $swf "_$swf"
    rm "_$swf"
done
ori=$(find . -iname "*.swf")
dst=""
for item in $ori
do
dst+="$(basename $item .swf)=$item "
done
echo $dst
#out=$(basename `pwd`)
swfcombine -Nazo ../$1.swf $ori
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
    <version></version>
    <!--
$ori
    -->
</role>" >>$1.xml
fi

