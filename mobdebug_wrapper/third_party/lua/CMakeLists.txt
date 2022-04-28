cmake_minimum_required( VERSION 3.21 )

project( lua )

set( CMAKE_C_STANDARD 17 )

add_library( lua
                STATIC
                lua/onelua.c)

target_include_directories( lua PUBLIC ./lua/)

set_property(TARGET lua PROPERTY POSITION_INDEPENDENT_CODE ON)

if (UNIX)
	target_link_libraries(lua m)
endif (UNIX)
