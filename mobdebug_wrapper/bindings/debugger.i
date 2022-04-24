%module debugger
%{
#include "debugger.h"
%}

struct Debugger* luad_create();

void luad_init(struct Debugger* self);
