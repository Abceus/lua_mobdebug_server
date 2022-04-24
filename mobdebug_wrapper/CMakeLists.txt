cmake_minimum_required( VERSION 3.21 )

project( mobdebug_wrapper )

set( CMAKE_C_STANDARD 17 )

add_library( mobdebug_wrapper
                SHARED
                sources/main.c
                sources/debugger.c)

add_subdirectory(third_party/lua)
add_subdirectory(third_party/luasocket)

target_include_directories( mobdebug_wrapper
        PUBLIC headers
        PRIVATE lua
        PRIVATE luasocket)

target_link_libraries(mobdebug_wrapper
        lua luasocket)