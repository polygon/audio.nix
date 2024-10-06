{ nixpkgs, home-manager, self, ... }:
nixpkgs.lib.nixosSystem {
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
              home.stateVersion = "24.05";
              home.username = lib.mkForce "audio";
              home.homeDirectory = "/home/audio";
              systemd.user.tmpfiles.rules =
                [ "d ${config.home.homeDirectory}/yabridgemgr - - - - -" ];
              systemd.user.services.winery = {
                Unit = {
                  Description = "Mount yabridge prefix";
                  After = [ "basic.target" ];
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

            });
          }
        ];
      };