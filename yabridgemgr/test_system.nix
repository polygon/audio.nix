{ nixpkgs, home-manager, self, system, ... }:
let pkgs = nixpkgs.legacyPackages.${system};
in nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    home-manager.nixosModules.home-manager
    {
      users.users.audio = {
        isNormalUser = true;
        initialPassword = "1234";
        extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
        linger = true;
      };
      users.users.root.initialPassword = "1234";
      i18n.defaultLocale = "en_US.UTF-8";
      console.keyMap = "de";
      security.sudo.wheelNeedsPassword = false;
    }
    {
      home-manager.users.audio = ({ config, lib, ... }: {
        home.packages = with pkgs; [ yabridge yabridgectl ];
        home.stateVersion = "24.05";
        home.username = lib.mkForce "audio";
        home.homeDirectory = "/home/audio";
        systemd.user.tmpfiles.rules =
          [ "d ${config.home.homeDirectory}/yabridgemgr - - - - -" ];
        systemd.user.services.yabridgemgr_mountprefix = {
          Unit = {
            Description = "Mount yabridge prefix";
            After = [ "systemd-tmpfiles-setup.service" ];
          };
          Install = { WantedBy = [ "default.target" ]; };
          Service = {
            RuntimeDirectory = "yabridgemgr";
            ExecStart = "${
                self.packages.${system}.mount_prefix
              }/bin/mount_prefix ${config.home.homeDirectory}/yabridgemgr";
            RemainAfterExit = "yes";
          };
        };

        systemd.user.services.yabridgemgr_sync = {
          Unit = {
            Description = "yabridgectl sync";
            After = [ "yabridgemgr_mountprefix.service" ];
          };
          Install = { WantedBy = [ "default.target" ]; };
          Service = {
            ExecStart = "${pkgs.yabridgectl}/bin/yabridgectl sync";
            RemainAfterExit = "yes";
          };
        };

        home.file."${config.xdg.configHome}/yabridgectl/config.toml".text = ''
          plugin_dirs = [
            '${config.home.homeDirectory}/yabridgemgr/drive_c/Program Files/Common Files/VST2',
            '${config.home.homeDirectory}/yabridgemgr/drive_c/Program Files/Common Files/VST3',
          ]
          vst2_location = 'centralized'
          no_verify = false
          blacklist = []
        '';

      });
    }
  ];
}
