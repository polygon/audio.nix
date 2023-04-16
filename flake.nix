{
  description = "Audio Nix packages and modules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
  };


  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    packages.${system} = {
      # Drumkits for DrumGizmo
      shittyKit = pkgs.callPackage ./drumkits/shittykit.nix { };

      # Various VSTs
      rvxx = pkgs.callPackage ./vst/rvxx.nix { };

      # Bitwig
      bitwig-studio4 = pkgs.callPackage ./bitwig/bitwig-studio4.nix { };
      bitwig-studio5-beta3 = pkgs.callPackage ./bitwig/bitwig-studio5-beta3.nix { };
    };

    nixosModules.default = import ./modules self;

    hmModule = import ./hm { inherit self; };     

    # NixOS Container for testing
    nixosConfigurations.devcontainer = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          {
            boot.isContainer = true;
            system.stateVersion = "22.11";
          }
          self.nixosModules.default
        ];
      };

  };
}
