#ifndef H_DEBUGGER
#define H_DEBUGGER

#include <lua.h>
#include "mobdebug_wrapper_exports.h"

enum DebuggerStatus {
    INVALID,
    INITED,
    RUNNING,
    BREAK
};

struct Breakpoint {
	char* filename;
	int line;
};

struct Debugger {
    lua_State* L;
	struct Breakpoint* currentBreakpoint;
};

typedef void (*ChangeStateCallbackFunction) (enum DebuggerStatus);

MOBDEBUG_WRAPPER_EXPORTS struct Debugger* luad_create();

void MOBDEBUG_WRAPPER_EXPORTS luad_init(struct Debugger* self);
void MOBDEBUG_WRAPPER_EXPORTS luad_run(struct Debugger* self);
void MOBDEBUG_WRAPPER_EXPORTS luad_update(struct Debugger* self);
void MOBDEBUG_WRAPPER_EXPORTS luad_stop(struct Debugger* self);
void MOBDEBUG_WRAPPER_EXPORTS luad_pause(struct Debugger* self);
void MOBDEBUG_WRAPPER_EXPORTS luad_setBreakpoint(struct Debugger* self, const char* filename, int line);
void MOBDEBUG_WRAPPER_EXPORTS luad_removeBreakpoint(struct Debugger* self, const char* filename, int line);
MOBDEBUG_WRAPPER_EXPORTS enum DebuggerStatus luad_getStatus(struct Debugger* self);
void MOBDEBUG_WRAPPER_EXPORTS luad_getCurrentBreakpoint(struct Debugger* self);
void MOBDEBUG_WRAPPER_EXPORTS luad_setStatusChangeCallback(struct Debugger* self, ChangeStateCallbackFunction function);
void MOBDEBUG_WRAPPER_EXPORTS luad_handle(struct Debugger* self, const char* command);

#endif