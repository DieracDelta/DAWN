{
  description = "Nix Debug Adapter Implementation (DAP)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix = {
      # url = "github:DieracDelta/nix?220aa8e0ac9d17de2c9f356a68be43b673d851a1";
      url = "github:DieracDelta/nix/220aa8e0ac9d17de2c9f356a68be43b673d851a1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, utils, fenix, ... }:
    utils.lib.eachDefaultSystem (system:
    let
    # --prefix=$(pwd)/outputs/out --enable-shared=no
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
            (prev: final:
              {
                nix = inputs.nix.packages.aarch64-darwin.nix
                  .overrideAttrs (oldAttrs: {
                    # env.NIX_CFLAGS_COMPILE = "-I${pkgs.libarchive.dev}/include";
                    # PKG_CONFIG_PATH="${pkgs.libiconv.override {enableStatic = true; enableShared = false;}}";
                    # NIX_LDFLAGS = "-L${pkgs.libiconv}/lib -liconv";
                    # LD_LIBRARY_PATH="${prev.libarchive.lib}/lib";
                    LIBARCHIVE_LIBS = "${pkgs.libiconv.override {enableStatic = true; enableShared = false;}}/lib/libiconv.a";
                    # LIBARCHIVE_CFLAGS = "-I${pkgs.libarchive.override {enableStatic = true; enableShared = false;}}/include/";
                    # configureFlags = [ "--prefix=$(pwd)/outputs/out" "--enable-shared=no" ];

                    # doCheck = false;

                    configureFlags = oldAttrs.configureFlags ++ [ "--enable-shared=no" ];
                    buildInputs = oldAttrs.buildInputs ++ [
                      prev.darwin.apple_sdk.frameworks.Security
                      prev.darwin.apple_sdk.frameworks.SystemConfiguration
                      prev.gtest
                      prev.curl
                      prev.bzip2 prev.xz prev.brotli prev.editline
                      prev.openssl prev.sqlite
                      # prev.libarchive
                      prev.boost
                    ];




                    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
                      # prev.libarchive.lib
                      # prev.libarchive.dev
                      # prev.libarchive.out
                      prev.darwin.apple_sdk.frameworks.Security
                      prev.darwin.apple_sdk.frameworks.SystemConfiguration

                    ];


                    propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [
                      prev.darwin.apple_sdk.frameworks.Security
                      prev.darwin.apple_sdk.frameworks.SystemConfiguration
                      # prev.libarchive.lib
                      # prev.libarchive.dev
                      # prev.libarchive.out
                    ];
                    postInstall = ''
                        cp src/libcmd/libnixcmd.a $out/lib/
                        cp src/libexpr/libnixexpr.a $out/lib/
                        cp src/libfetchers/libnixfetchers.a $out/lib/
                        cp src/libmain/libnixmain.a $out/lib/
                        cp src/libstore/libnixstore.a $out/lib/
                        cp src/libutil/libnixutil.a $out/lib/
                    '';
                  });
              }
            )
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
                # TODO fix this...
                # nix
                mdbook
                nodejs_latest
                cargo-expand
              ] ++
              pkgs.lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.Security pkgs.libiconv darwin.apple_sdk.frameworks.SystemConfiguration ];
          };
    });
}
