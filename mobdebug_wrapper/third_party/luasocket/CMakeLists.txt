cmake_minimum_required( VERSION 3.21 )

project( luasocket )

set( CMAKE_C_STANDARD 17 )

set( CORE_SOURCES ./luasocket/src/luasocket.c
./luasocket/src/timeout.c
./luasocket/src/buffer.c
./luasocket/src/io.c
./luasocket/src/auxiliar.c
./luasocket/src/compat.c
./luasocket/src/options.c
./luasocket/src/inet.c
./luasocket/src/except.c
./luasocket/src/select.c
./luasocket/src/tcp.c
./luasocket/src/udp.c )

if (UNIX)
    set( PLATFORM_SOURCES ./luasocket/src/usocket.c )
endif (UNIX)

if (WIN32)
    set( PLATFORM_SOURCES ./luasocket/src/wsocket.c )
endif (WIN32)

add_library( luasocket
				STATIC
                ${CORE_SOURCES}
                ${PLATFORM_SOURCES})

target_include_directories( luasocket PUBLIC ./luasocket/src/)

target_link_libraries(luasocket lua)

if(WIN32)
  target_link_libraries(luasocket wsock32 ws2_32)
endif()
