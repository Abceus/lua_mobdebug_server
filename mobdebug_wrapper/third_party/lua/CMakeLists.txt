cmake_minimum_required( VERSION 3.21 )

project( lua )

set( CMAKE_C_STANDARD 17 )

add_library( lua
                SHARED
                lua/onelua.c)

target_link_libraries(lua m)
