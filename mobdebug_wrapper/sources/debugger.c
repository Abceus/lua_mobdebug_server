#include "debugger.h"
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <lua.h>
#include <luasocket.h>
#include <lauxlib.h>
#include <string.h>

static const char Key = 'k';

struct Debugger* luad_create() {
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);
    luaL_requiref(L, "socket.core", luaopen_socket_core, 1);
    if(luaL_dofile(L, "mobdebug_wrapper/scripts/mobdebug_wrapper.lua")) {
        printf("Error: %s\n", lua_tostring(L, -1));
        fflush(stdout);
        return NULL;
    }
    struct Debugger* result = malloc(sizeof(struct Debugger));

    lua_pushlightuserdata(L, (void *)&Key);
    lua_pushvalue(L, -2); 
    lua_settable(L, LUA_REGISTRYINDEX);

    lua_remove(L, -1);

    result->L = L;
    return result;
}

void luad_init(struct Debugger* self) {
    lua_pushlightuserdata(self->L, (void *)&Key);
    lua_gettable(self->L, LUA_REGISTRYINDEX);
    if(lua_getfield(self->L, -1, "init") == LUA_TFUNCTION) {
        lua_pushvalue(self->L, -2);
        if(lua_pcall(self->L, 1, 0, 0) != LUA_OK) {
            printf("Error: %s", lua_tostring(self->L, -1));
            fflush(stdout);
        }
    }
    lua_remove(self->L, -1);
}

void luad_run(struct Debugger* self) {
    lua_pushlightuserdata(self->L, (void *)&Key);
    lua_gettable(self->L, LUA_REGISTRYINDEX);
    if(lua_getfield(self->L, -1, "run") == LUA_TFUNCTION) {
        lua_pushvalue(self->L, -2);
        if(lua_pcall(self->L, 1, 0, 0) != LUA_OK) {
            printf("Error: %s\n", lua_tostring(self->L, -1));
            fflush(stdout);
        }
    }
    else {
        printf("Error: not found run function\n");
    }
    lua_remove(self->L, -1);
}

void luad_update(struct Debugger* self) {
    lua_pushlightuserdata(self->L, (void *)&Key);
    lua_gettable(self->L, LUA_REGISTRYINDEX);
    if(lua_getfield(self->L, -1, "update") == LUA_TFUNCTION) {
        lua_pushvalue(self->L, -2);
        if(lua_pcall(self->L, 1, 0, 0) != LUA_OK) {
            printf("Error: %s", lua_tostring(self->L, -1));
            fflush(stdout);
        }
    }
    lua_remove(self->L, -1);
}

void luad_stop(struct Debugger* self) {
    lua_pushlightuserdata(self->L, (void *)&Key);
    lua_gettable(self->L, LUA_REGISTRYINDEX);
    if(lua_getfield(self->L, -1, "stop") == LUA_TFUNCTION) {
        lua_pushvalue(self->L, -2);
        lua_pcall(self->L, 1, 0, 0);
    }
    lua_remove(self->L, -1);
}

void luad_pause(struct Debugger* self) {
    lua_pushlightuserdata(self->L, (void *)&Key);
    lua_gettable(self->L, LUA_REGISTRYINDEX);
    if(lua_getfield(self->L, -1, "pause") == LUA_TFUNCTION) {
        lua_pushvalue(self->L, -2);
        if(lua_pcall(self->L, 1, 0, 0) != LUA_OK) {
            printf("Error: %s", lua_tostring(self->L, -1));
            fflush(stdout);
        }
    }
    lua_remove(self->L, -1);
}

void luad_setBreakpoint(struct Debugger* self, const char* filename, int line) {
    lua_pushlightuserdata(self->L, (void *)&Key);
    lua_gettable(self->L, LUA_REGISTRYINDEX);
    if(lua_getfield(self->L, -1, "setBreakpoint") == LUA_TFUNCTION) {
        lua_pushvalue(self->L, -2);
        lua_pushstring(self->L, filename);
        lua_pushinteger(self->L, line);
        lua_pcall(self->L, 3, 0, 0);
    }
    lua_remove(self->L, -1);
}

void luad_removeBreakpoint(struct Debugger* self, const char* filename, int line) {
    lua_pushlightuserdata(self->L, (void *)&Key);
    lua_gettable(self->L, LUA_REGISTRYINDEX);
    if(lua_getfield(self->L, -1, "removeBreakpoint") == LUA_TFUNCTION) {
        lua_pushvalue(self->L, -2);
        lua_pushstring(self->L, filename);
        lua_pushinteger(self->L, line);
        lua_pcall(self->L, 3, 0, 0);
    }
    lua_remove(self->L, -1);
}

enum DebuggerStatus getStatusFromString(const char* str) {
    struct Pair {
        char* name;
        enum DebuggerStatus status;
    };

    struct Pair map[] = {
        {
            .name = "invalid",
            .status = INVALID
        },
        {
            .name = "inited",
            .status = INITED
        },
        {
            .name = "running",
            .status = RUNNING
        },
        {
            .name = "break",
            .status = BREAK
        }
    };

    size_t arraySize = sizeof(map) / sizeof(struct Pair);

    for(size_t i = 0; i < arraySize; ++i) {
        struct Pair* p = &map[i];
        if(strcmp(str, p->name) == 0) {
            return p->status;
        }
    }
    return INVALID;
}

enum DebuggerStatus luad_getStatus(struct Debugger* self) {
    lua_pushlightuserdata(self->L, (void *)&Key);
    lua_gettable(self->L, LUA_REGISTRYINDEX);
    if(lua_getfield(self->L, -1, "getStatus") == LUA_TFUNCTION) {
        lua_pushvalue(self->L, -2);
        lua_pcall(self->L, 1, 1, 0);
        const char* resultStr = lua_tostring(self->L, -1);
        enum DebuggerStatus result = getStatusFromString(resultStr);
        lua_remove(self->L, -1);
        return result;
    }
    return INVALID;
}

struct lua_callback {
    ChangeStateCallbackFunction callback;
    struct Debugger* debugger;
};

struct lua_callback currentCallback;

int changeStateCallbackFunctionWrapper(lua_State* state) {
    const char* currentStatus = lua_tostring(currentCallback.debugger->L, -1);
    currentCallback.callback(getStatusFromString(currentStatus));
    return 0;
}

void luad_setStatusChangeCallback(struct Debugger* self, ChangeStateCallbackFunction function) {
    currentCallback.callback = function;
    currentCallback.debugger = self;
    lua_pushlightuserdata(self->L, (void *)&Key);
    lua_gettable(self->L, LUA_REGISTRYINDEX);
    if(lua_getfield(self->L, -1, "setStatusChangeCallback") == LUA_TFUNCTION) {
        lua_pushvalue(self->L, -2);
        lua_pushcfunction(self->L, changeStateCallbackFunctionWrapper);
        lua_pcall(self->L, 2, 0, 0);
    }
    lua_remove(self->L, -1);
}

void luad_handle(struct Debugger* self, const char* command) {
    lua_pushlightuserdata(self->L, (void *)&Key);
    lua_gettable(self->L, LUA_REGISTRYINDEX);
    if(lua_getfield(self->L, -1, "handle") == LUA_TFUNCTION) {
        lua_pushvalue(self->L, -2);
        lua_pushstring(self->L, command);
        lua_pcall(self->L, 2, 0, 0);
    }
    lua_remove(self->L, -1);
}