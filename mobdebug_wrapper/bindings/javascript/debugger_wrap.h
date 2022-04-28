
#ifndef MYOBJECT_H
#define MYOBJECT_H

#include <node.h>
#include <node_object_wrap.h>
extern "C" {
#include <debugger.h>
}

namespace debugger {
    class DebuggerWrap : public node::ObjectWrap {
    public:
        static void Init(v8::Local<v8::Object> exports);

    private:
        explicit DebuggerWrap(Debugger* value);
        ~DebuggerWrap();

        static void New(const v8::FunctionCallbackInfo<v8::Value>& args);
        
        static void LuaInit(const v8::FunctionCallbackInfo<v8::Value>& args);

        static void Run(const v8::FunctionCallbackInfo<v8::Value>& args);

        Debugger*  value_;
    };
}

#endif