{
  description = "Muk flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, nixpkgs, ... }@inputs: 
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      nixosConfigurations.muk = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ 
          ./configuration.nix 
          ./hardware-configuration.nix 
        ];
      };
    };
}
