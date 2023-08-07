#include <nix/config.h>
#include <nix/eval-inline.hh>
#include <nix/eval.hh>
#include <nix/globals.hh>
#include <nix/primops.hh>
#include <algorithm>
#include<iostream>
#include <dlfcn.h>
#include <iostream>
#include <iterator>
#include <optional>
#include <ostream>
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

extern "C" void discourage_linker_from_discarding() {}

static void enable_dap(EvalState &state, const PosIdx pos, Value **args,
                       Value &v) {
  state.debugRepl = myDebugRepl;
}

class PluginInstance {
  Context *context;
  // RegisterPrimOp primop;

public:
  // constructor
  PluginInstance()
      // :
        // primop({
        //     .name = "enable-dap",
        //     .args = {},
        //     .doc = "lol",
        //     .fun = enable_dap,
        //     .experimentalFeature = {},
        // })
  {
    context = initialize_plugin();
  }

  // destructor
  ~PluginInstance() { deinitialize_plugin(context); }
};

    // addFlag({
    //     .longName = "debugger",
    //     .description = "Start an interactive environment if evaluation fails.",
    //     .category = MixEvalArgs::category,
    //     .handler = {&startReplOnEvalErrors, true},
    // });

// global variable that will be initialized when the plugin is dl-open-ed
PluginInstance x{};
