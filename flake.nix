{
  description = "Nix Debug Adapter Implementation (DAP)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-release = {
      url = "github:NixOS/nix?ref=2.17.0";
    };
  };

  outputs = inputs@{ self, nixpkgs, utils, fenix, nix-release }:
    utils.lib.eachDefaultSystem (system:
    let
        fenixStable = fenix.packages.${system}.latest.withComponents [ "cargo" "clippy" "rust-src" "rustc" "rustfmt" "llvm-tools-preview" ];
        overlaid = final: prev:
          {
            rustc = fenixStable;
            cargo = fenixStable;
            rust-src = fenixStable;
            nix = nix-release.packages.${system}.nix-clang11Stdenv;
          };
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            overlaid
          ];
        };
        in {
          # use clang 11 because nix's clang is 11
          # annoying link errors if we try clang 15
          devShell = pkgs.mkShell.override { stdenv = pkgs.clang11Stdenv; } {
            shellHook = ''
              export CARGO_TARGET_DIR="$(git rev-parse --show-toplevel)/target_dirs/nix_rustc";
            '';
            RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
            buildInputs =
              with pkgs; [
                rust-src
                pkg-config
                fenixStable
                fenix.packages.${system}.rust-analyzer
                just
                cargo-expand
                cargo
                rustc
                nix
                nix.dev
                bear
                rust-cbindgen # for executable cbindgen
                clang-tools_15 # for up to date clangd
                clang_11
                boost
                protobuf
                pkg-config
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
