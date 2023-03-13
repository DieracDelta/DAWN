# What is this?

NDA (nix debug adapter) is a implementation of the DAP adapter for the nix debugger.

# Configuration

Configuration for neovim:

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
