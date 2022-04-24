cmake_minimum_required( VERSION 3.21 )

project( mobdebug_wrapper )

set( CMAKE_C_STANDARD 17 )

add_library( mobdebug_wrapper
                SHARED
                sources/main.c
                sources/debugger.c
                bindings/debugger_wrap.c)

add_subdirectory(third_party/lua)
add_subdirectory(third_party/luasocket)

target_include_directories( mobdebug_wrapper
        PUBLIC headers
        PRIVATE lua
        PRIVATE luasocket
        PRIVATE /usr/include/python3.10/)

target_link_libraries(mobdebug_wrapper
        lua luasocket python3)