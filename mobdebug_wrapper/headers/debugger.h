#ifndef H_DEBUGGER
#define H_DEBUGGER

#include <lua.h>


struct Debugger {
    lua_State *L;
    // int luaObjectIndex;
};

enum DebuggerStatus {
    INVALID,
    INITED,
    RUNNING,
    BREAK
};

typedef void (*ChangeStateCallbackFunction) (enum DebuggerStatus);

struct Debugger* luad_create();

void luad_init(struct Debugger* self);
void luad_run(struct Debugger* self);
void luad_update(struct Debugger* self);
void luad_stop(struct Debugger* self);
void luad_pause(struct Debugger* self);
void luad_setBreakpoint(struct Debugger* self, const char* filename, int line);
void luad_removeBreakpoint(struct Debugger* self, const char* filename, int line);
enum DebuggerStatus luad_getStatus(struct Debugger* self);
void luad_setStatusChangeCallback(struct Debugger* self, ChangeStateCallbackFunction function);
void luad_handle(struct Debugger* self, const char* command);

#endif