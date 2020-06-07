/*********************************************************************
 * Copyright (c) 2020 Red Hat, Inc.
 *
 * This program and the accompanying materials are made
 * available under the terms of the Eclipse Public License 2.0
 * which is available at https://www.eclipse.org/legal/epl-2.0/
 *
 * SPDX-License-Identifier: EPL-2.0
 **********************************************************************/

 /**
  * This module is a rewrite of the original module.
  * It is now using NODE_BUILTIN_MODULE_CONTEXT_AWARE module.
  * Imports to node_internals and node_api instead of napi.h
  * Change initialization logic and use namespaces
  */

#include <node.h>
#include <node_api.h>
#include "node_internals.h"
#include <uv.h>
#include <v8.h>
#include "env-inl.h"
#include "node_native_module_env.h"
#include "node_options.h"

namespace node {

  using v8::Context;
  using v8::DontDelete;
  using v8::DontEnum;
  using v8::FunctionCallbackInfo;
  using v8::FunctionTemplate;
  using v8::HandleScope;
  using v8::Integer;
  using v8::Local;
  using v8::MaybeLocal;
  using v8::Object;
  using v8::PropertyAttribute;
  using v8::ReadOnly;
  using v8::Signature;
  using v8::String;
  using v8::Value;

  namespace deasync {

    static void Run(const FunctionCallbackInfo<Value>& args) {
      uv_run(node::GetCurrentEventLoop(v8::Isolate::GetCurrent()), UV_RUN_ONCE);
      return args.GetReturnValue().SetUndefined();
    }

   void Initialize(Local<Object> target,
                    Local<Value> unused,
                    Local<Context> context,
                    void* priv) {
      Environment* env = Environment::GetCurrent(context);
      env->SetMethod(target, "run", Run);
    }

  } // namespace deasync
} // namespace node

NODE_MODULE_CONTEXT_AWARE_INTERNAL(deasync, node::deasync::Initialize);
