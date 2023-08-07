default: build lint test

build:
  echo Building nix dap adapter..
  cargo build --release --workspace --examples --bins --tests

build_bindings:
  echo Building nix dap adapter..
  cargo build --release --package dawn-bindings

run_plugin_mbp:
  nix --option plugin-files ./target_dirs/nix_rustc/debug/libnix_bindings.dylib repl

test:
  echo Testing nix dap adapter...
  cargo test --release --workspace -- --nocapture --test-threads=1

clean:
  echo Cleaning...
  cargo clean

lint:
  echo Linting…
  cargo clippy --release --workspace --examples --bins --tests

fmt:
  cargo fmt

fix:
  cargo fix --allow-dirty --allow-staged

doc:
  cargo doc --workspace --open
