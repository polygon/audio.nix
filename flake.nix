{
  description = "Audio Nix packages and modules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
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
      atlas2 = pkgs.callPackage ./vst/atlas2.nix { };
      plugdata = pkgs.callPackage ./vst/plugdata.nix { };

      # Bitwig
      bitwig-studio4 = pkgs.callPackage ./bitwig/bitwig-studio4.nix { };
      bitwig-studio5-beta3 = pkgs.callPackage ./bitwig/bitwig-studio5-beta3.nix { };
      bitwig-studio5-beta5 = pkgs.callPackage ./bitwig/bitwig-studio5-beta5.nix { };
      bitwig-studio5-beta6 = pkgs.callPackage ./bitwig/bitwig-studio5-beta6.nix { };
      bitwig-studio5-beta8 = pkgs.callPackage ./bitwig/bitwig-studio5-beta8.nix { };
      bitwig-studio5-beta9 = pkgs.callPackage ./bitwig/bitwig-studio5-beta9.nix { };
      bitwig-studio5-beta10 = pkgs.callPackage ./bitwig/bitwig-studio5-beta10.nix { };
      bitwig-studio5-beta11 = pkgs.callPackage ./bitwig/bitwig-studio5-beta11.nix { };
      bitwig-studio5-beta12 = pkgs.callPackage ./bitwig/bitwig-studio5-beta12.nix { };
      bitwig-studio5-beta13 = pkgs.callPackage ./bitwig/bitwig-studio5-beta13.nix { };
      bitwig-studio5 = pkgs.callPackage ./bitwig/bitwig-studio-5.0.nix { };
      bitwig-studio5-1-beta1 = pkgs.callPackage ./bitwig/bitwig-studio-5.1-beta1.nix { };
      bitwig-studio5-latest = self.packages.${system}.bitwig-studio5-1-beta1;

      # Chow plugins
      chow-centaur = pkgs.callPackage ./chow/chow-centaur.nix { };  
      chow-kick = pkgs.callPackage ./chow/chow-kick.nix { };  
      chow-phaser = pkgs.callPackage ./chow/chow-phaser.nix { };  
      chow-tape-model = pkgs.callPackage ./chow/chow-tape-model.nix { };  
      chow-multitool = pkgs.callPackage ./chow/chow-multitool.nix { };
    };


    nixosModules.default = import ./modules self;

    hmModule = import ./hm { inherit self; };     

    # NixOS Container for testing
    nixosConfigurations.devcontainer = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          {
            boot.isContainer = true;
            system.stateVersion = "23.05";
          }
          self.nixosModules.default
        ];
      };

  };
}
