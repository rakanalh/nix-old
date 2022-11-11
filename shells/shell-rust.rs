let
  mozillaOverlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz); 
  nixpkgs = import <nixpkgs> { overlays = [ mozillaOverlay ]; };
  toolchain = with nixpkgs; (rustChannelOf { channel = "nightly"; });
  rust-nightly = toolchain.rust.override {
    targets = [ "wasm32-unknown-unknown" ];
  };
in
with nixpkgs; pkgs.mkShell {
  buildInputs = [
    clang
    llvmPackages.clang
    cmake
    pkg-config
    rust-nightly
    nodejs
    yarn
    docker-compose
  ];

  LIBCLANG_PATH = "${pkgs.llvmPackages_11.libclang.lib}/lib";
  # LIBCLANG_PATH = "${llvmPackages.libclang}/lib";
  PROTOC = "${protobuf}/bin/protoc";
  RUST_SRC_PATH = "${toolchain.rust-src}/lib/rustlib/src/rust/library/";
  ROCKSDB_LIB_DIR = "${rocksdb}/lib";
}
