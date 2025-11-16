{
  description = "Audio Nix packages and modules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nix-buildproxy = 
      { 
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
    in {
      packages.${system} = {
        # Toosl
        kmidimon = pkgs.callPackage ./kmidimon.nix { };
        # Various VSTs
        amplocker = pkgs.callPackage ./vst/amplocker { };
        atlas2 = pkgs.callPackage ./vst/atlas2.nix { };
        plugdata = pkgs.callPackage ./vst/plugdata.nix { };
        paulxstretch = pkgs.callPackage ./vst/paulxstretch.nix { };
        vital = pkgs.callPackage ./vst/vital.nix { };
        ripplerx = pkgs.callPackage ./vst/ripplerx.nix { };
        aida-x = pkgs.callPackage ./vst/aida-x.nix { };

        # Bitwig
        bitwig-studio4 = pkgs.callPackage ./bitwig/bitwig-studio4.nix { };
        bitwig-studio5 = pkgs.callPackage ./bitwig/bitwig-studio-5.0.nix { };
        bitwig-studio5-1 = pkgs.callPackage ./bitwig/bitwig-studio-5.1.nix { };
        bitwig-studio5-2-unwrapped =
          pkgs.callPackage ./bitwig/bitwig-studio-5.2.nix { };
        bitwig-studio5-3-unwrapped =
          pkgs.callPackage ./bitwig/bitwig-studio-5.3.nix { };
        bitwig-studio6-0-beta-unwrapped =
          pkgs.callPackage ./bitwig/bitwig-studio-6.0-beta.nix { };
        #        bitwig-studio5-3-beta-unwrapped =
        #          pkgs.callPackage ./bitwig/bitwig-studio-5.3-beta.nix { };

        bitwig-studio5-2 = pkgs.callPackage ./bitwig/bitwig-bubblewrap.nix {
          bitwig-studio = self.packages.${system}.bitwig-studio5-2-unwrapped;
        };
        bitwig-studio5-3 = pkgs.callPackage ./bitwig/bitwig-bubblewrap.nix {
          bitwig-studio = self.packages.${system}.bitwig-studio5-3-unwrapped;
        };
        bitwig-studio6-0-beta =
          pkgs.callPackage ./bitwig/bitwig-bubblewrap.nix {
            bitwig-studio =
              self.packages.${system}.bitwig-studio6-0-beta-unwrapped;
          };

        #        bitwig-studio5-3-beta =
        #          pkgs.callPackage ./bitwig/bitwig-bubblewrap.nix {
        #            bitwig-studio =
        #              self.packages.${system}.bitwig-studio5-3-beta-unwrapped;
        #          };
        bitwig-studio6-latest = self.packages.${system}.bitwig-studio6-0-beta;
        bitwig-studio5-stable-latest = self.packages.${system}.bitwig-studio5-3;

        # Chow plugins
        chow-centaur = pkgs.callPackage ./chow/chow-centaur.nix { };
        chow-kick = pkgs.callPackage ./chow/chow-kick.nix { };
        chow-phaser = pkgs.callPackage ./chow/chow-phaser.nix { };
        chow-tape-model = pkgs.callPackage ./chow/chow-tape-model.nix { };
        chow-multitool = pkgs.callPackage ./chow/chow-multitool.nix { };

        libonnxruntime-neuralnote =
          pkgs.callPackage ./vst/neuralnote/libonnxruntime-neuralnote.nix { };
        neuralnote = pkgs.callPackage ./vst/neuralnote/neuralnote.nix {
          libonnxruntime-neuralnote =
            self.packages.${system}.libonnxruntime-neuralnote;
        };
        grainbow = pkgs.callPackage ./vst/grainbow { };
        papu = pkgs.callPackage ./vst/papu.nix { };

        # yabridgemgr plugins
        wine-valhalla =
          pkgs.callPackage ./yabridgemgr/plugins/valhalla_supermassive.nix { };
        wine-voxengo-span =
          pkgs.callPackage ./yabridgemgr/plugins/voxengo_span.nix { };
        wine-midichordanalyzer =
          pkgs.callPackage ./yabridgemgr/plugins/piz_midichordanalyzer.nix { };

        # Mainly used for dev, squashfs image in results
        build_prefix =
          pkgs.callPackage ./yabridgemgr/plumbing/build_prefix.nix {
            username = "audio";
            plugins = [
              self.packages.${system}.wine-valhalla
              self.packages.${system}.wine-voxengo-span
              self.packages.${system}.wine-midichordanalyzer
            ];
          };
      };

      overlays.default = (final: prev: {
        atlas2 = self.packages.${system}.atlas2;
        plugdata = self.packages.${system}.plugdata;
        paulxstretch = self.packages.${system}.paulxstretch;
        bitwig-studio4 = self.packages.${system}.bitwig-studio4;
        bitwig-studio5 = self.packages.${system}.bitwig-studio5-3;
        bitwig-studio-latest = self.packages.${system}.bitwig-studio6-latest;
        bitwig-studio-stable-latest =
          self.packages.${system}.bitwig-studio5-stable-latest;
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
        kmidimon = self.packages.${system}.kmidimon;
        ripplerx = self.packages.${system}.ripplerx;
        aida-x = self.packages.${system}.aida-x;
      });

      devShells.${system}.juce = pkgs.callPackage ./devshell/juce.nix { };
      templates.juce = {
        path = ./templates/juce-flake;
        description = "DevShell starter for JUCE projects";
      };

      nixosConfigurations.yabridgemgr_test =
        (import ./yabridgemgr/test_system.nix) { inherit nixpkgs system self; };

      nixosModules.yabridgemgr =
        ((import ./yabridgemgr/module.nix) { inherit self system; });
    };
}
