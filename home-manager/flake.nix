{
  description = "Home Manager configuration of monzey";

  inputs = {
    nixpkgs.follows = "nixos-unstable";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    mcp-hub.url = "github:ravitemer/mcp-hub";
    # The shell's pinned Quickshell 0.3.0 does not build with Qt 6.12.
    shell-nixpkgs.url = "github:nixos/nixpkgs/b51242d7d43689db2f3be91bd05d5b24fbb469c4";
    shell = {
      url = "path:../desktop/caelestia";
      inputs.nixpkgs.follows = "shell-nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nixos-unstable, mcp-hub, shell, ... }@inputs: 
    let
      system = "x86_64-linux";
      mkHome = host: home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
        };

        extraSpecialArgs = {
          inherit system;
          inherit inputs;
          unstablePkgs = import nixos-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        };

        modules = [
          ./hosts/${host}.nix
        ];
      };
    in {
      homeConfigurations = {
        "monzey@muk" = mkHome "muk";
        "monzey@gardevoir" = mkHome "gardevoir";
      };
    };
}
