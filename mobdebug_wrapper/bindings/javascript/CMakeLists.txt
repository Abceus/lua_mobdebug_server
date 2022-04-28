cmake_minimum_required( VERSION 3.21 )

project( javascript )

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules)
find_package (Nodejs REQUIRED)

IF(NODE_VERSION_MINOR LESS_EQUAL 10)
  #Try generate node module for nodejs with swig, but this shit not working
  FIND_PACKAGE(SWIG REQUIRED)
  INCLUDE(${SWIG_USE_FILE})
  INCLUDE_DIRECTORIES(${NODE_INCLUDE_DIRS} ${CMAKE_CURRENT_SOURCE_DIR}/..)
  message(info dfghjhfg ${NODE_ROOT_DIR})
  SET(CMAKE_SWIG_FLAGS "")


  set (V8_VERSION_HEX 0x0${V8_VERSION_MAJOR}${V8_VERSION_MINOR}${V8_VERSION_PATCH})
  string (LENGTH "${V8_VERSION_HEX}" V8_VERSION_HEX_length)
  while (V8_VERSION_HEX_length LESS 8)
    set (V8_VERSION_HEX "${V8_VERSION_HEX}0")
    message (DEBUG " - Padded V8 version to match SWIG format")
    string (LENGTH "${V8_VERSION_HEX}" V8_VERSION_HEX_length)
  endwhile ()

  # SET_SOURCE_FILES_PROPERTIES(debugger.i PROPERTIES SWIG_FLAGS "-includeall")
  # set_property(SOURCE ../debugger.i PROPERTY SWIG_FLAGS -node )
  set_property(SOURCE ../debugger.i PROPERTY SWIG_FLAGS -v8 -DV8_VERSION=${V8_VERSION_HEX})
  set_property(SOURCE ../debugger.i PROPERTY CPLUSPLUS ON) 
  SWIG_ADD_LIBRARY(debugger TYPE MODULE LANGUAGE javascript SOURCES ../debugger.i)
  SWIG_LINK_LIBRARIES(debugger mobdebug_wrapper)
ELSE()

ENDIF()