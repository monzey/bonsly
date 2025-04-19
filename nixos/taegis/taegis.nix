{ stdenv, fetchurl, dpkg, kmod }:

{ pkgs ? import <nixpkgs> {} } : pkgs.stdenv.mkDerivation rec {
  pname = "taegis-agent";
  version = "1.4.2";

  src = fetchurl {
    url = "https://fichiers.septeo.fr/index.php/s/iMSnwQxsJxGaxPm/download/taegis-agent_1.4.2_amd64.deb";
    sha256 = "0870q27xzmcvnvk76pvx55q7s31z4j1cpnxxyvgz4nnc9p1k1fjg";
  };

  nativeBuildInputs = [ dpkg ];
  buildInputs = [ kmod ];

  unpackPhase = "dpkg -x $src $out";

#   installPhase = ''
#     $out/opt/secureworks/taegis-agent/bin/taegisctl register
#   '';
}