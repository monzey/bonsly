{
  description = "Home Manager configuration of monzey";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
    gemini = {
      url = "path:./modules/gemini-cli";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nixos-unstable, hyprpanel, ... }@inputs: 
    let
      system = "x86_64-linux";
      # pkgs = nixpkgs.legacyPackages.${system};
      # unstablePkgs = nixos-unstable.legacyPackages.${system};
    in {
      homeConfigurations."monzey" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            inputs.hyprpanel.overlay
          ];
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
          ./home.nix
        ];
      };
    };
}
