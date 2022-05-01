#include <lua.h>
#include <stddef.h>
#include <stdio.h>
#include <stdbool.h>
#include <assert.h>

#include "test.h"
#include "debugger.h"

struct Debugger* d;

void printChahgedStatus(enum DebuggerStatus newStatus) {
    printf("Status changed. New status: %d\n", newStatus);
    if(newStatus == BREAK) {
        printf("Continue\n");
        luad_getCurrentBreakpoint(d);
		if(d->currentBreakpoint != NULL) {
			printf("Program breaked in file %s line %d\n", d->currentBreakpoint->filename, d->currentBreakpoint->line);
		}
        luad_run(d);
    }
}

int main() {
    d = luad_create();
    luad_init(d);
    luad_setStatusChangeCallback(d, printChahgedStatus);
    // printf("%d\n", luad_getStatus(d));
    // printf("%d\n", luad_getStatus(d));
    // luad_pause(d);
    // printf("%d\n", luad_getStatus(d));
    // luad_setBreakpoint(d, "d:/workspace/lua_debug/test.lua", 7);
    luad_setBreakpoint(d, "start.lua", 12);
    // luad_removeBreakpoint(d, "./test.lua", 12);
    luad_connect(d);
    luad_run(d);
    while(true) {
        luad_update(d);
        // printf("Print your command: \n");
        // size_t bufferSize = 256;
        // char command[bufferSize];
        // fgets(&command, bufferSize, stdin);
        // luad_handle(d, command);
        // if(luad_getStatus(d) == BREAK) {
        //     printf("Continue");
        //     luad_run(d);
        // }
    }
    return 0;
}