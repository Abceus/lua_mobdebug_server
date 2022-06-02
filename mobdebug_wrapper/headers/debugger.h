#ifndef H_DEBUGGER
#define H_DEBUGGER

#include <lua.h>
#include "collection.h"
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
void MOBDEBUG_WRAPPER_EXPORTS luad_connect(struct Debugger* self);
void MOBDEBUG_WRAPPER_EXPORTS luad_run(struct Debugger* self);
void MOBDEBUG_WRAPPER_EXPORTS luad_step(struct Debugger* self);
void MOBDEBUG_WRAPPER_EXPORTS luad_over(struct Debugger* self);
void MOBDEBUG_WRAPPER_EXPORTS luad_out(struct Debugger* self);
void MOBDEBUG_WRAPPER_EXPORTS luad_reload(struct Debugger* self);
void MOBDEBUG_WRAPPER_EXPORTS luad_done(struct Debugger* self);
void MOBDEBUG_WRAPPER_EXPORTS luad_exit(struct Debugger* self);
void MOBDEBUG_WRAPPER_EXPORTS luad_update(struct Debugger* self);
void MOBDEBUG_WRAPPER_EXPORTS luad_stop(struct Debugger* self);
void MOBDEBUG_WRAPPER_EXPORTS luad_pause(struct Debugger* self);
void MOBDEBUG_WRAPPER_EXPORTS luad_setBreakpoint(struct Debugger* self, const char* filename, int line);
void MOBDEBUG_WRAPPER_EXPORTS luad_removeBreakpoint(struct Debugger* self, const char* filename, int line);
void MOBDEBUG_WRAPPER_EXPORTS luad_removeAllBreakpoints(struct Debugger* self);
MOBDEBUG_WRAPPER_EXPORTS struct Collection* luad_getAllBrealpoints(struct Debugger* self);
MOBDEBUG_WRAPPER_EXPORTS enum DebuggerStatus luad_getStatus(struct Debugger* self);
void MOBDEBUG_WRAPPER_EXPORTS luad_getCurrentBreakpoint(struct Debugger* self);
void MOBDEBUG_WRAPPER_EXPORTS luad_setStatusChangeCallback(struct Debugger* self, ChangeStateCallbackFunction function);
void MOBDEBUG_WRAPPER_EXPORTS luad_handle(struct Debugger* self, const char* command);
MOBDEBUG_WRAPPER_EXPORTS struct Stack* luad_getStack(struct Debugger* self);
MOBDEBUG_WRAPPER_EXPORTS int luad_setWatch(struct Debugger* self, const char* expression);
void MOBDEBUG_WRAPPER_EXPORTS luad_removeWatch(struct Debugger* self, int index);
MOBDEBUG_WRAPPER_EXPORTS char* luad_getWatch(struct Debugger* self, int index);
MOBDEBUG_WRAPPER_EXPORTS struct Collection* luad_getAllWatches(struct Debugger* self);
void MOBDEBUG_WRAPPER_EXPORTS luad_removeAllWatches(struct Debugger* self);
MOBDEBUG_WRAPPER_EXPORTS int luad_getCurrentWatchId(struct Debugger* self);
MOBDEBUG_WRAPPER_EXPORTS struct Stack* luad_evaluates(struct Debugger* self, const char* expression);
MOBDEBUG_WRAPPER_EXPORTS struct Stack* luad_execute(struct Debugger* self, const char* expression);

const int LUAD_INVALID_INDEX = -1;

void MOBDEBUG_WRAPPER_EXPORTS luad_test(struct Debugger* self);

#endif