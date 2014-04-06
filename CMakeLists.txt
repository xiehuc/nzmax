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
