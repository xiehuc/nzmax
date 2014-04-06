project(nz)
cmake_minimum_required(VERSION 2.8)

set(proj "libnz")
configure_file(cmake/project.in libnz/.project)
configure_file(libnz/actionScriptProperties.in libnz/.actionScriptProperties)
