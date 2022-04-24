cmake_minimum_required( VERSION 3.21 )

project( server_terminal )

set( CMAKE_C_STANDARD 17 )

add_subdirectory(../mobdebug_wrapper mobdebug_wrapper)

add_executable( server_terminal
                sources/main.c)

target_link_libraries( server_terminal mobdebug_wrapper )

target_include_directories( server_terminal
        PRIVATE headers)