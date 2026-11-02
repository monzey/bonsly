{
  description = "Bonsly NixOS hosts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, nixpkgs, ... }@inputs: 
    let
      system = "x86_64-linux";
      mkHost = host: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./hosts/${host} ];
      };
    in {
      nixosConfigurations = {
        muk = mkHost "muk";
        gardevoir = mkHost "gardevoir";
      };
    };
}
