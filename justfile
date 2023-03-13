default: build lint test

build:
  echo Building nix dap adapter..
  cargo build --release --workspace --examples --bins --tests

test:
  echo Testing nix dap adapter...
  cargo test --release --workspace -- --nocapture --test-threads=1

clean:
  echo Cleaning...
  cargo clean

lint:
  echo Linting…
  cargo clippy --release --workspace --examples --bins --tests
  cargo fmt

fmt:
  cargo fmt

fix:
  cargo fix --allow-dirty --allow-staged

doc:
  cargo doc --workspace --open
