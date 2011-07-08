CC= mxmlc
VPATH=src
CFLAGS=  

#LDFLAGS= -ldl
LDFLAGS= 

all:nzmaxi

nzmaxi: 
	$(CC) $(CFLAGS) src/Main.mxml -library-path+=lib  -incremental=true -benchmark=false -optimize=true -static-link-runtime-shared-libraries=true -o bin/nzmaxi.swf



dist:
	zip -r source.zip ./ -x source.zip
