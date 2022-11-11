{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    # Deps
    binaryen
    jq
    jemalloc
    clang
    cmake
    llvmPackages.clang
    openssl
    openssl.dev
    pkg-config
  ];

  LIBCLANG_PATH = "${pkgs.llvmPackages_11.libclang.lib}/lib";
  # LIBCLANG_PATH = "${llvmPackages.libclang}/lib";
  # PROTOC = "${protobuf}/bin/protoc";
}
