{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs
    , ...
    }:

    let
      system = "x86_64-linux";

      kicadWithPlugin = final: prev: {
        # Create a package that contains a kicad plugin located at
        # ${PKGROOT}/plugins.
        kicadComponentLayout = prev.callPackage ./pkgs/kicad/plugin.nix { };

        kicad = prev.kicad.overrideAttrs (oldAttrs: {
          # Include the kicad plugin package in the install.
          # Is this the correct way?
          propagatedBuildInputs = [ pkgs.kicadComponentLayout ];
          # Add pyyaml to the Python environment of Kicad so above plugin
          # loads.
          pythonPath = oldAttrs.pythonPath ++ [ prev.python3Packages.pyyaml ];
          # "prev.python3Packages" isn't right.  We are not using the same
          # reference to pythonPackages, so that could go wrong.

          # Looks like these env's can have multiple set like PATH.  Set the
          # first 3RD_PARTY path to ${PKGROOT} of the plugin.
          makeWrapperArgs = oldAttrs.makeWrapperArgs ++ [
            "--prefix KICAD6_3RD_PARTY : ${pkgs.kicadComponentLayout}"
          ];
        });
      };
      pkgs =
        import nixpkgs {
          inherit system;
          overlays = [
            kicadWithPlugin
          ];
        };
    in
    {
      # `nix run`
      packages.x86_64-linux.default = pkgs.kicad;
    };
}
