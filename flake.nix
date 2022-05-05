{
  description = "Audio related Nix packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };


  outputs = { self, nixpkgs }:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in
  {
    packages.x86_64-linux = {
      drumkits.shittyKit = pkgs.callPackage ./drumkits/shittykit.nix { };
      vst.rvxx = pkgs.callPackage ./vst/rvxx.nix { };
    };

    hmModule = import ./hm { inherit self; };     
  };
}
