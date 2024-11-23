{ nixpkgs, home-manager, self, system, ... }:
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
      hardware.pulseaudio.enable = true;
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
      environment.systemPackages = with pkgs; [ carla ];
    }
    self.nixosModules.yabridgemgr
    {
      modules.audio-nix.yabridgemgr = {
        user = "audio";
        enable = true;
      };
    }
    {
      # environment.systemPackages = with pkgs; [ yabridge yabridgectl ];
      # systemd.user.tmpfiles.rules = let
      #   ybcfg = pkgs.writeText "yabridgecfg" ''
      #     plugin_dirs = [
      #       'yabridgemgr/drive_c/Program Files/Common Files/VST2',
      #       'yabridgemgr/drive_c/Program Files/Common Files/VST3',
      #     ]
      #     vst2_location = 'centralized'
      #     no_verify = false
      #     blacklist = []
      #   '';
      # in [
      #   "d %h/yabridgemgr - - - - -"
      #   "C %h/.config/yabridgectl/config.toml - - - - ${ybcfg}"
      # ];
      # systemd.user.services.yabridgemgr_mountprefix = {
      #   description = "Mount yabridge prefix";
      #   after = [ "systemd-tmpfiles-setup.service" ];
      #   wantedBy = [ "default.target" ];
      #   serviceConfig = {
      #     RuntimeDirectory = "yabridgemgr";
      #     ExecStart = "${
      #         self.packages.${system}.mount_prefix
      #       }/bin/mount_prefix yabridgemgr";
      #     RemainAfterExit = "yes";
      #   };
      # };
      # systemd.user.services.yabridgemgr_sync = {
      #   description = "yabridgectl sync";
      #   after = [ "yabridgemgr_mountprefix.service" ];
      #   wantedBy = [ "default.target" ];
      #   serviceConfig = {
      #     ExecStart = "${pkgs.yabridgectl}/bin/yabridgectl sync";
      #     ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
      #     Environment = "NIX_PROFILES=/run/current-system/sw";
      #     RemainAfterExit = "yes";
      #   };
      # };
    }
  ];
}
