{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , ...
    }:
    let
      lib = nixpkgs.lib;
    in
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
      formatter.aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.nixpkgs-fmt;

      nixosConfigurations = {
          pinixos = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = [
              ({...}: {
                users.mutableUsers = false;
                users.users."demo".isNormalUser = true;
              })
              (home-manager.nixosModules.home-manager {
                home-manager.useGlobalPkgs = true;
                # UseGlobalPkgs means nixpkgs override declaration must happen outside of
                # home-manager, otherwise the override will not be evaluated.
                home-manager.useUserPackages = true;
                home-manager.users.demo = import ./user/demo.nix;
              })
              ({nixpkgs, ...}: {
                # See above comment about the overlay
                nixpkgs.overlays = [ (import ./overlays/mopidy.nix) ];
              })
            ];
          };
        };
    };
}
