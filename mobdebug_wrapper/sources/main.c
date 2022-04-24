#include "test.h"
#include <lua.h>
#include <stdio.h>
#include <lauxlib.h>
#include <assert.h>


void test(const char* filename, int line) {
    printf("Breakpoint added in file %s in line %d", filename, line);

    lua_State *L;
    L = luaL_newstate();

    luaL_openlibs(L);

    luaL_loadfile(L, "mobdebug_wrapper/scripts/mobdebug_wrapper.lua");
    lua_pcall(L, 0, 1, 0);
    assert(lua_getfield(L, -1, "addBreakpoint") == LUA_TFUNCTION);
    lua_pushvalue(L, -2);
    lua_remove(L, -3);
    lua_pushstring(L, "This is filename");
    lua_pushinteger(L, 228);
    lua_pcall(L, 3, 0, 0);
}