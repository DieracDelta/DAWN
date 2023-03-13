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

  outputs = { self, nixpkgs, utils, fenix }:
    utils.lib.eachDefaultSystem (system:
    let
        fenixStable = fenix.packages.${system}.stable.withComponents [ "cargo" "clippy" "rust-src" "rustc" "rustfmt" "llvm-tools-preview" ];
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
            LD_LIBRARY_PATH = "${pkgs.zlib}/lib";
            buildInputs =
              with pkgs; [
                fenixStable fenix.packages.${system}.rust-analyzer
                just
              ] ++
              pkgs.lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.Security pkgs.libiconv darwin.apple_sdk.frameworks.SystemConfiguration ];
          };
    });
}
