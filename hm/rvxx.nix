{ self }:
{ pkgs, config, lib, ... }:

with lib;
let
  rvxx = self.packages.${pkgs.system}.rvxx;
  bwrap = "${pkgs.bubblewrap}/bin/bwrap";
in
{
  options.audio.vst.rvxx.enable = mkEnableOption "RVXX";
  options.audio.vst.rvxx.path = mkOption {
      type = types.str;
      default = "$HOME/audio/rvxx";
      description = "Path prefix for RVXX";
  };

  config = mkIf config.audio.vst.rvxx.enable
  {
    audio.audioenv.enable = true;
    audio.audioenv.bwrap_args = [
      ''--dir /opt/Audio\ Assault/RVXX''
      ''--bind ${config.audio.vst.rvxx.path}/settings.px /opt/Audio\ Assault/RVXX/settings.px''
      ''--ro-bind ${rvxx}/RVXX\ v2\ Standalone /opt/Audio\ Assault/RVXX/RVXX\ v2\ Standalone''
      ''--ro-bind "${rvxx}/Presets" "/opt/Audio Assault/RVXX/Presets/orig"''
      ''--ro-bind "${rvxx}/IRs" "/opt/Audio Assault/RVXX/IRs/orig"''
    ];
    home.packages = 
    [ 
      (pkgs.writeShellApplication {
        name = "RVXX";
        
        text = ''
          audioenv ${rvxx}/RVXX\ v2\ Standalone
        '';
 
        checkPhase = "";
      })  
    ];
    home.activation = {
     rvxx = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD mkdir -p ${config.audio.vst.rvxx.path}
        $DRY_RUN_CMD mkdir -p ${config.audio.vst.rvxx.path}/Presets
        $DRY_RUN_CMD mkdir -p ${config.audio.vst.rvxx.path}/IRs
        $DRY_RUN_CMD touch ${config.audio.vst.rvxx.path}/settings.px
     '';
    };
    home.file.".vst/RVXX v2.so".source = "${rvxx}/RVXX v2.so";
  };
}
