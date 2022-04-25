cmake_minimum_required( VERSION 3.21 )

project( mobdebug_wrapper )

set( CMAKE_C_STANDARD 17 )

add_subdirectory( bindings )

add_library( mobdebug_wrapper
                SHARED
                sources/main.c
                sources/debugger.c
				m_exports.h)

include(GenerateExportHeader)

generate_export_header(mobdebug_wrapper
    BASE_NAME mobdebug_wrapper
    EXPORT_MACRO_NAME MOBDEBUG_WRAPPER_EXPORTS
    EXPORT_FILE_NAME mobdebug_wrapper_exports.h
    STATIC_DEFINE SHARED_EXPORTS_BUILT_AS_STATIC)

add_subdirectory(third_party/lua)
add_subdirectory(third_party/luasocket)

target_include_directories( mobdebug_wrapper
        PUBLIC headers
        PRIVATE lua
        PRIVATE luasocket
		PUBLIC ${CMAKE_CURRENT_BINARY_DIR})

target_link_libraries(mobdebug_wrapper
        lua luasocket)