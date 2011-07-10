CC= mxmlc
VPATH=src
CFLAGS=  

#LDFLAGS= -ldl
LDFLAGS= 

all:nzmaxi

nzmaxi: 
	$(CC) $(CFLAGS) src/Main.mxml -debug=true -library-path+=lib -static-link-runtime-shared-libraries=true -o bin/nzmaxi.swf;\
		cp bin/nzmaxi.swf /var/www/nzmaxi/nzmaxi.swf;\
		chmod +rx /var/www/nzmaxi/nzmaxi.swf

dist:
	zip -r source.zip ./ -x source.zip
