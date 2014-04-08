project(nz)
cmake_minimum_required(VERSION 2.8)

set(proj "libnz")
set(nature "flexlibnature")
configure_file(cmake/project.in libnz/.project)
configure_file(libnz/actionScriptProperties.in libnz/.actionScriptProperties @ONLY)

set(proj "nzmaxi")
set(nature "flexnature")
configure_file(cmake/project.in nzmaxi/.project)
configure_file(nzmaxi/actionScriptProperties.in nzmaxi/.actionScriptProperties @ONLY)

set(proj "nzmax")
configure_file(cmake/airproject.in nzmax/.project)
configure_file(nzmax/actionScriptProperties.in nzmax/.actionScriptProperties @ONLY)

set(proj "nzmaxm")
set(mobile_nature "<nature>com.adobe.flexide.project.multiplatform.multiplatformnature</nature>")
configure_file(cmake/airproject.in nzmaxm/.project)
configure_file(nzmaxm/actionScriptProperties.in nzmaxm/.actionScriptProperties @ONLY)

set(proj "nztools")
set(nature "flexnature")
configure_file(cmake/project.in nztools/.project)
configure_file(nztools/actionScriptProperties.in nztools/.actionScriptProperties @ONLY)
