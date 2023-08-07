# What is this?

DAWN (Debug Adapter with Nix) is an implementation of the DAP adapter for the nix debugger.

# Configuration

Configuration for Neovim:

```lua
-- configure the dap adapter
local dap = require("dap")
dap.adapters.nix = {
    type = "executable",
    executable = {
        command = "/Users/jrestivo/dev/nix-debug-adapter/target_dirs/nix_rustc/release/nix-debug-adapter",
        args = {},
    },
}
-- configure the dap configuration
dap.configurations.nix = {
    type = "nix",
    request = "launch",
    name = "Launch Program (nix debug adapter)",
    program = "$${file}",
}
```

# Usage

No usage yet, still WIP.

To test:

on m1 mbp

```
nix --option plugin-files ./target_dirs/nix_rustc/debug/libnix_bindings.dylib repl
```

will print out hello world

# Design

- DAWN crate
    - Build overarching .so file that builds as plugin for rust
- REP
    - Figure out frontend rep. I think it will match the DAP rep, so keeping it in the same crate makes sense
- bindings crate
    - FFI between nix and rust
    - Initializes and maintains debugging state

- Figure out how to communicate (e.g. which port, etc). It might be possible to do over stdin/stdout, but likely would need to check.
- Figure out how to get stuff out of nix.


# Thanks

*Massive* thanks to https://github.com/lf-. The `nix-bindings` crate is entirely based on their https://github.com/lf-/nix-otel project, and as it currently stands is basically a copy and paste of their code here: https://github.com/lf-/nix-dap-demo-stuff. They spent several hours working through setting up a nix plugin (nontrivial) and explaining their code to me.

Thanks to the Hiro Systems team, who maintains the debug adapter infrastructure that is heavily used by the dap-server crate.
