#!/bin/sh

if [ ! -e ../bin/story ]; then
	ln -s ../share/story ../bin/
fi
if [ ! -e ../bin/comlib ]; then
	ln -s ../share/comlib ../bin/
fi
adl src/nzmax-app.xml ../bin
