{
  description = "Gemini CLI via FHS wrapper";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      packages.${system}.gemini = pkgs.buildFHSEnv {
        name = "gemini-fhs";

        targetPkgs = pkgs: with pkgs; [
          nodejs
          bash
          curl
          git
        ];

        runScript = ''
          bash -c '
            export GEMINI_HOME="$HOME/.gemini-npm"
            export PATH="$GEMINI_HOME/bin:$PATH"
            export npm_config_prefix="$GEMINI_HOME"
            export HOME="$HOME"

            if ! command -v gemini >/dev/null 2>&1; then
              echo "[+] Installing @google/gemini-cli into $GEMINI_HOME..."
              npm install -g @google/gemini-cli
            fi

            exec gemini "$@"
          ' bash "$@"
        '';
      };

      defaultPackage.${system} = self.packages.${system}.gemini;
    };
}
