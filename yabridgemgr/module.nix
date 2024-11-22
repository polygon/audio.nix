{ self, system }:
{ config, lib, pkgs, ... }:

with lib;

# Base config for all Linux systems

let cfg = config.modules.audio-nix.yabridgemgr;
in {
  options.modules.audio-nix.yabridgemgr = {
    enable = mkEnableOption "Yabridgemgr";
    user = mkOption {
      type = types.str;
      description = "User for yabridgemgr";
    };
    plugins = mkOption {
      type = types.listOf types.package;
      default = [ self.packages.${system}.wine-valhalla ];
      description = "Plugin packages to install";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ yabridge yabridgectl ];
    systemd.user.tmpfiles.users."${cfg.user}".rules = let
      ybcfg = pkgs.writeText "yabridgecfg" ''
        plugin_dirs = [
          'yabridgemgr/drive_c/Program Files/Common Files/VST2',
          'yabridgemgr/drive_c/Program Files/Common Files/VST3',
        ]
        vst2_location = 'centralized'
        no_verify = false
        blacklist = []
      '';
    in [
      "d %h/yabridgemgr - - - - -"
      "C %h/.config/yabridgectl/config.toml - - - - ${ybcfg}"
    ];
    systemd.user.services.yabridgemgr_mountprefix = let
      build_prefix = pkgs.callPackage ./plumbing/build_prefix.nix {
        username = cfg.user;
        plugins = cfg.plugins;
      };
      mount_prefix = pkgs.callPackage ./plumbing/mount_prefix.nix {
        wineprefix = build_prefix;
      };
    in {
      description = "Mount yabridge prefix";
      after = [ "systemd-tmpfiles-setup.service" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        RuntimeDirectory = "yabridgemgr";
        ExecStart = "${mount_prefix}/bin/mount_prefix yabridgemgr";
        RemainAfterExit = "yes";
      };
      unitConfig = { ConditionUser = "${cfg.user}"; };
    };
    systemd.user.services.yabridgemgr_sync = {
      description = "yabridgectl sync";
      after = [ "yabridgemgr_mountprefix.service" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.yabridgectl}/bin/yabridgectl sync";
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
        Environment = "NIX_PROFILES=/run/current-system/sw";
        RemainAfterExit = "yes";
      };
      unitConfig = { ConditionUser = "${cfg.user}"; };
    };

  };
}
