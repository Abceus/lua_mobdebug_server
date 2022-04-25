cmake_minimum_required( VERSION 3.21 )

project( bindings )

if (BINDING_ENABLE_PYTHON)
  add_subdirectory(python)
endif()

if (BINDING_ENABLE_LUA)
  add_subdirectory(lua)
endif()

if (BINDING_ENABLE_JAVASCRIPT)
  add_subdirectory(javascript)
endif()