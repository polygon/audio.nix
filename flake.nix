{
  description = "Audio related Nix packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };


  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem ["x86_64-linux"] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.drumkits.shittyKit = pkgs.callPackage ./drumkits/shittykit.nix { };
        packages.vst.rvxx = pkgs.callPackage ./vst/rvxx.nix { };
      }
    ) // {
      hmModule = import ./hm { inherit self; };     
    };
}
