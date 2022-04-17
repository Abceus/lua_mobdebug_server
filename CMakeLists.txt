cmake_minimum_required( VERSION 3.9 )

project( lua_mobdebug_server )

set( CMAKE_CXX_STANDARD 20 )

add_subdirectory(third_party/asio)

add_executable( lua_mobdebug_server
        main.cpp)

target_link_libraries( lua_mobdebug_server
	PRIVATE
	asio)