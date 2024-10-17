{
  description = "Audio Nix packages and modules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nix-buildproxy = {
      url = "github:polygon/nix-buildproxy/v0.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };


  outputs = { self, nixpkgs, nix-buildproxy }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [ nix-buildproxy.overlays.default ];
    };
  in
  {
    packages.${system} = {
      # Various VSTs
      amplocker = pkgs.callPackage ./vst/amplocker { };
      atlas2 = pkgs.callPackage ./vst/atlas2.nix { };
      plugdata = pkgs.callPackage ./vst/plugdata.nix { };
      paulxstretch = pkgs.callPackage ./vst/paulxstretch.nix { };
      vital = pkgs.callPackage ./vst/vital.nix { };

      # Bitwig
      bitwig-studio4 = pkgs.callPackage ./bitwig/bitwig-studio4.nix { };
      bitwig-studio5 = pkgs.callPackage ./bitwig/bitwig-studio-5.0.nix { };
      bitwig-studio5-1 = pkgs.callPackage ./bitwig/bitwig-studio-5.1.nix { };
      bitwig-studio5-2 = pkgs.callPackage ./bitwig/bitwig-studio-5.2.nix { };
      bitwig-studio5-2-beta = pkgs.callPackage ./bitwig/bitwig-studio-5.2-beta.nix { };
      bitwig-studio5-latest = self.packages.${system}.bitwig-studio5-2;
      bitwig-studio5-stable-latest = self.packages.${system}.bitwig-studio5-2;

      # Chow plugins
      chow-centaur = pkgs.callPackage ./chow/chow-centaur.nix { };  
      chow-kick = pkgs.callPackage ./chow/chow-kick.nix { };  
      chow-phaser = pkgs.callPackage ./chow/chow-phaser.nix { };  
      chow-tape-model = pkgs.callPackage ./chow/chow-tape-model.nix { };  
      chow-multitool = pkgs.callPackage ./chow/chow-multitool.nix { };

      libonnxruntime-neuralnote = pkgs.callPackage ./vst/neuralnote/libonnxruntime-neuralnote.nix { };
      neuralnote = pkgs.callPackage ./vst/neuralnote/neuralnote.nix { libonnxruntime-neuralnote = self.packages.${system}.libonnxruntime-neuralnote; };
      grainbow = pkgs.callPackage ./vst/grainbow { };
      papu = pkgs.callPackage ./vst/papu.nix { };
    };

    overlays.default = (final: prev: {
      atlas2 = self.packages.${system}.atlas2;
      plugdata = self.packages.${system}.plugdata;
      paulxstretch = self.packages.${system}.paulxstretch;
      bitwig-studio4 = self.packages.${system}.bitwig-studio4;
      bitwig-studio5 = self.packages.${system}.bitwig-studio5;
      bitwig-studio5-latest = self.packages.${system}.bitwig-studio5-latest;
      bitwig-studio5-stable-latest = self.packages.${system}.bitwig-studio5-stable-latest;
      chow-centaur = self.packages.${system}.chow-centaur;
      chow-kick = self.packages.${system}.chow-kick;
      chow-phaser = self.packages.${system}.chow-phaser;
      chow-tape-model = self.packages.${system}.chow-tape-model;
      chow-multitool = self.packages.${system}.chow-multitool;
      neuralnote = self.packages.${system}.neuralnote;
      vital = self.packages.${system}.vital;
      amplocker = self.packages.${system}.amplocker;
      grainbow = self.packages.${system}.grainbow;
      papu = self.packages.${system}.papu;
    });

    devShells.${system}.juce = pkgs.callPackage ./devshell/juce.nix { };
  };
}
