{ nixpkgs, self, system, ... }:
let pkgs = nixpkgs.legacyPackages.${system};
in nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    {
      users.users.audio = {
        isNormalUser = true;
        initialPassword = "1234";
        extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
        linger = true;
      };
      users.users.user2 = {
        isNormalUser = true;
        initialPassword = "1234";
        extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
        linger = true;
      };
      users.users.root.initialPassword = "1234";
      i18n.defaultLocale = "en_US.UTF-8";
      console.keyMap = "de";
      security.sudo.wheelNeedsPassword = false;
      nix = {
        extraOptions = ''
          experimental-features = nix-command flakes
        '';
      };
      hardware.pulseaudio.enable = false;
      hardware.pulseaudio.support32Bit = true;
    }
    {
      nixpkgs.config.pulseaudio = true;
      services.xserver = {
        enable = true;
        desktopManager = {
          xterm.enable = false;
          xfce.enable = true;
        };
      };
      services.displayManager.defaultSession = "xfce";
      environment.systemPackages = with pkgs; [ carla firefox ];
    }
    {
      imports = [ "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix" ];
      virtualisation.qemu.options = [
        "-smp 4"
        "-m 4096"
        "-audiodev pipewire,id=audiodev1"
        "-device intel-hda"
        "-device hda-duplex,audiodev=audiodev1"
      ];
    }
    self.nixosModules.yabridgemgr
    {
      modules.audio-nix.yabridgemgr = {
        user = "audio";
        enable = true;
      };
    }
  ];
}
