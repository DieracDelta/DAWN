{
  description = "Nix Debug Adapter Implementation (DAP)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, utils, fenix, ... }:
    utils.lib.eachDefaultSystem (system:
    let
        fenixStable = fenix.packages.${system}.latest.withComponents [ "cargo" "clippy" "rust-src" "rustc" "rustfmt" "llvm-tools-preview" ];
        rustOverlay = final: prev:
          {
            rustc = fenixStable;
            cargo = fenixStable;
            rust-src = fenixStable;
          };
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            rustOverlay
          ];
        };
        in {
          devShell = pkgs.mkShell {
            shellHook = ''
              export CARGO_TARGET_DIR="$(git rev-parse --show-toplevel)/target_dirs/nix_rustc";
            '';
            RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
            buildInputs =
              with pkgs; [
                pkg-config
                fenixStable
                fenix.packages.${system}.rust-analyzer
                just
                cargo-expand
                nix
                nix.dev
                bear
                rust-cbindgen # for executable cbindgen
                clang-tools_15
                boost
                protobuf
              ] ++
              pkgs.lib.optionals stdenv.isDarwin [
                darwin.apple_sdk.frameworks.Security
                pkgs.libiconv
                darwin.apple_sdk.frameworks.SystemConfiguration
              ];
          };
          test = builtins.enable-dap;
    });
}
