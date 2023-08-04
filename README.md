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

# Thanks

*Massive* thanks to https://github.com/lf-. The `nix-bindings` crate is entirely based on their https://github.com/lf-/nix-otel project, and as it currently stands is basically a copy paste of their code here: https://github.com/lf-/nix-dap-demo-stuff. They spent several hours working through setting up a nix plugin (nontrivial) and explaining their code to me.

Thanks to the Hiro Systems team, who maintains the debug adapter infrastructure is heavily used by the dap-server crate.
