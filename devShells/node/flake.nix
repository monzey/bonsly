{
  description = "Flake providing a devshell with nvm";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells = {
        node22 = pkgs.mkShell {
          name = "node22-shell";

          buildInputs = [
            pkgs.nodejs_22
          ];
        };
      };
    });
}
