===============
nzmax project
===============

逆转裁判游戏同人引擎，
本游戏引擎基于flex+air技术构建，具有跨平台，界面美观的特点

nizhuan game engine,
build on flex and air, cross platform, beautiful ui

.. image:: http://nzmaxi.sinaapp.com/screenshot.png

structure
===========

+  libnz: the common core for nzmax*
+  nzmaxi: the internet version, can play in a web browser online_
+  nzmax:  the desktop version, open with adobe air and enjoy full functional
+  nzmaxm: the mobile version, can play with ios and android
+  nztools: a tool to view role.swf 's emotions

.. _online: http://nzmaxi.sinaapp.com/

build
=======

install sdk
-------------

1.  install apache flex sdk and adobe air sdk
2.  set FLEX\_HOME and PLAYERGLOBAL\_HOME=%FLEX_HOME%\\frameworks\\libs\\player
    (windows) or PLAYERGLOBAL\_HOME=${FLEX_HOME}/frameworks/libs/player (linux)
    environment
3.  download globalplayer.swc and put it to ${PLAYERGLOBAL_HOME}/11.1

build with Flash Develop
--------------------------

`Flash Develop`__ is a free tool under windows to develop with flash.

1.  open libnz, and use ``compc -load-config+=build.xml`` to build libnz.swc
2.  open each of *nzmaxi* *nzmax* *nzmaxm* folder, open \*.as3proj with flash
    develop and compile
3.  open nzmax/bat, run CreateCertificate.bat to make a cert file
4.  open nzmax, run PackageApp.bat to make a archived air file

__ http://www.flashdevelop.org/

limit: do not support package nzmaxm

build with command line
-------------------------

in linux and mac osx, you can also build without any ide tools.

1.  run ./build.sh under root of source
