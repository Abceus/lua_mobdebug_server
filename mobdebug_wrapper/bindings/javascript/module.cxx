#include "v8.h"
#include <node.h>
#include "debugger_wrap.h"

namespace debugger {
    using v8::FunctionCallbackInfo;
    using v8::Isolate;
    using v8::Local;
    using v8::Object;
    using v8::String;
    using v8::Value;
    using v8::Context;

    // Debugger* luad_createMethod(const FunctionCallbackInfo<Value>& args) {
    //     Isolate* isolate = args.GetIsolate();
    //     Local<Context> context = isolate->GetCurrentContext();
    //     auto value = luad_create();
    //     Local<Object> res = Object::New(isolate);
    //     res->Set(context, value);
    // }

    // void Initialize(Local<Object> exports) {
    //     NODE_SET_METHOD(exports, "luad_create", luad_createMethod);
    // }

    void InitAll(Local<Object> exports) {
        DebuggerWrap::Init(exports);
    }

    NODE_MODULE(NODE_GYP_MODULE_NAME, InitAll)

}