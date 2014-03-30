#!/bin/sh
CERT_NAME=nzmax
CERT_FILE=bat/nzmax.p12
CERT_PASS=fd
APP_XML=application.xml
AIR_OUTPUT=../bin/nzmax.air
APP_DIR=../bin
SOURCE_DIR=`dirname $(pwd)`
SIGNING_OPTIONS=-storetype\ pkcs12\ -keystore\ ${CERT_FILE}\ -storepass\ ${CERT_PASS}

amxmlc -load-config+=build.xml src/nzmax.mxml

if [ ! -e ${CERT_FILE} ] ; then
	adt -certificate -cn ${CERT_NAME} 1024-RSA ${CERT_FILE} ${CERT_PASS}
fi

adt -package ${SIGNING_OPTIONS} ${AIR_OUTPUT} ${APP_XML} -C ../bin nzmax.swf
#-C ${APP_DIR}
