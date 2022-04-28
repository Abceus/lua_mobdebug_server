#include <node.h>
#include <node_object_wrap.h>
extern "C" {
#include <debugger.h>
}
#include "debugger_wrap.h"

namespace debugger {
    using v8::Context;
    using v8::Function;
    using v8::FunctionCallbackInfo;
    using v8::FunctionTemplate;
    using v8::Isolate;
    using v8::Local;
    using v8::Number;
    using v8::Object;
    using v8::ObjectTemplate;
    using v8::String;
    using v8::Value;

    DebuggerWrap::DebuggerWrap(Debugger* value) : value_(value) {
    }

    DebuggerWrap::~DebuggerWrap() {
    }

    void DebuggerWrap::Init(Local<Object> exports) {
        Isolate* isolate = exports->GetIsolate();
        Local<Context> context = isolate->GetCurrentContext();

        Local<ObjectTemplate> addon_data_tpl = ObjectTemplate::New(isolate);
        addon_data_tpl->SetInternalFieldCount(1);  // 1 field for the MyObject::New()
        Local<Object> addon_data =
            addon_data_tpl->NewInstance(context).ToLocalChecked();

        // Prepare constructor template
        Local<FunctionTemplate> tpl = FunctionTemplate::New(isolate, New, addon_data);
        tpl->SetClassName(String::NewFromUtf8(isolate, "DebuggerWrap").ToLocalChecked());
        tpl->InstanceTemplate()->SetInternalFieldCount(1);

        // Prototype
        NODE_SET_PROTOTYPE_METHOD(tpl, "init", LuaInit);
        NODE_SET_PROTOTYPE_METHOD(tpl, "run", Run);

        Local<Function> constructor = tpl->GetFunction(context).ToLocalChecked();
        addon_data->SetInternalField(0, constructor);
        exports->Set(context, String::NewFromUtf8(
            isolate, "DebuggerWrap").ToLocalChecked(),
            constructor).FromJust();
    }

    void DebuggerWrap::New(const FunctionCallbackInfo<Value>& args) {
        Isolate* isolate = args.GetIsolate();
        Local<Context> context = isolate->GetCurrentContext();

        if (args.IsConstructCall()) {
            // Invoked as constructor: `new MyObject(...)`
            DebuggerWrap* obj = new DebuggerWrap(luad_create());
            obj->Wrap(args.This());
            args.GetReturnValue().Set(args.This());
        } 
        // else {
        //     // Invoked as plain function `MyObject(...)`, turn into construct call.
        //     const int argc = 1;
        //     Local<Value> argv[argc] = { args[0] };
        //     Local<Function> cons =
        //         args.Data().As<Object>()->GetInternalField(0).As<Function>();
        //     Local<Object> result =
        //         cons->NewInstance(context, argc, argv).ToLocalChecked();
        //     args.GetReturnValue().Set(result);
        // }
    }

    void DebuggerWrap::LuaInit(const FunctionCallbackInfo<Value>& args) {
        Isolate* isolate = args.GetIsolate();

        DebuggerWrap* obj = ObjectWrap::Unwrap<DebuggerWrap>(args.Holder());
        luad_init(obj->value_);
    }

    void DebuggerWrap::Run(const FunctionCallbackInfo<Value>& args) {
        Isolate* isolate = args.GetIsolate();

        DebuggerWrap* obj = ObjectWrap::Unwrap<DebuggerWrap>(args.Holder());
        luad_run(obj->value_);
    }
}