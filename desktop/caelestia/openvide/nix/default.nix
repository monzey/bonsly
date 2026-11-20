{ lib, rustPlatform }:

{
  codex = rustPlatform.buildRustPackage {
    pname = "openvide-codex";
    version = "0.1.0";
    src = lib.fileset.toSource {
      root = ../codex;
      fileset = lib.fileset.unions [
        ../codex/Cargo.toml
        ../codex/Cargo.lock
        ../codex/src
        ../codex/tests
      ];
    };
    cargoLock.lockFile = ../codex/Cargo.lock;
  };
}
