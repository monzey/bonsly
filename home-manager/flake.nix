{
  description = "Home Manager configuration of monzey";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nixos-unstable, ... }@inputs: 
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      unstablePkgs = nixos-unstable.legacyPackages.${system};
    in {
      homeConfigurations."monzey" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;  
        extraSpecialArgs = {
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
