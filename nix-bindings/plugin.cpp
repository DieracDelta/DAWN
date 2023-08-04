#include <algorithm>
#include<iostream>
#include <nix/config.h>
#include <dlfcn.h>
#include <eval-inline.hh>
#include <eval.hh>
#include <globals.hh>
#include <iostream>
#include <iterator>
#include <optional>
#include <ostream>
#include <primops.hh>
#include <string_view>

#if HAVE_BOEHMGC

#include <gc/gc.h>
#include <gc/gc_cpp.h>

#endif

#include "./nix_dap_plugin.h"

using namespace nix;

static void myDebugRepl(ref<EvalState> state, const ValMap &vs) {
  //
}

static void enable_dap(EvalState &state, const PosIdx pos, Value **args,
                       Value &v) {
  state.debugRepl = myDebugRepl;
}

class PluginInstance {
  Context *context;
  RegisterPrimOp primop;

public:
  // constructor
  PluginInstance()
      : primop({
            .name = "enable-dap",
            .args = {},
            .doc = "lol",
            .fun = enable_dap,
            .experimentalFeature = {},
        }) {
    context = initialize_plugin();
  }

  // destructor
  ~PluginInstance() { deinitialize_plugin(context); }
};

// global variable that will be initialized when the plugin is dl-open-ed
PluginInstance x{};
