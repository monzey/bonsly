{ lazygit, fetchFromGitHub }:

lazygit.overrideAttrs (old: rec {
  version = "0.66.3";
  src = fetchFromGitHub {
    owner = "jesseduffield";
    repo = "lazygit";
    tag = "v${version}";
    hash = "sha256-L1L6ElQIGU1NgUdtDre60zGtZDScWFl8ioj/yuk/SmE=";
  };
  patches = (old.patches or []) ++ [ ./patches/lazygit-openvide-context.patch ];
  checkPhase = ''
    runHook preCheck
    go test ./pkg/gui/presentation ./pkg/config
    runHook postCheck
  '';
})
