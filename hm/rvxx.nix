{ self }:
{ pkgs, config, lib, ... }:

with lib;
let
  rvxx = self.packages.${pkgs.system}.vst.rvxx;
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
    home.packages = 
    let
      wrappa = ''
        blacklist=(/nix /dev /proc)
        declare -a auto_mounts
        for dir in /*; do
            if [[ -d "$dir" ]] && [[ ! "''${blacklist[@]}" =~ "$dir" ]]; then
            auto_mounts+=(--bind "$dir" "$dir")
            fi
        done
        declare -a irs
        for ir in ${rvxx}/IRs/*; do
          ir=''${ir##*/}
          irs+=(--ro-bind "${rvxx}/IRs/$ir" "/opt/Audio Assault/RVXX/IRs/$ir")
        done
        declare -a presets
        for preset in ${rvxx}/Presets/*; do
          preset=''${preset##*/}
          presets+=(--ro-bind "${rvxx}/Presets/$preset" "/opt/Audio Assault/RVXX/Presets/$preset")
        done
        cmd=(
            ${bwrap}
            --dev-bind /dev /dev
            --proc /proc
            --ro-bind /nix /nix
            "''${auto_mounts[@]}"
            --dir /opt/Audio\ Assault
            --bind ${config.audio.vst.rvxx.path} /opt/Audio\ Assault/RVXX
            --ro-bind ${rvxx}/RVXX\ v2\ Standalone /opt/Audio\ Assault/RVXX/RVXX\ v2\ Standalone
            "''${irs[@]}"
            "''${presets[@]}"
        )
      '';
    in
    [ 
      (pkgs.writeShellApplication {
        name = "RVXX";
        
        text = wrappa + ''
        cmd+=(${rvxx}/RVXX\ v2\ Standalone)
        exec "''${cmd[@]}"
        '';

        checkPhase = "";
      })
      (pkgs.writeShellApplication {
        name = "audioenv";
        
        text = wrappa + ''
        cmd+=("$@")
        exec "''${cmd[@]}"
        '';

        checkPhase = "";
      })      
    ];
    home.activation = {
     rvxx = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD mkdir -p ${config.audio.vst.rvxx.path}
        $DRY_RUN_CMD mkdir -p ${config.audio.vst.rvxx.path}/Presets
        $DRY_RUN_CMD mkdir -p ${config.audio.vst.rvxx.path}/IRs
     '';
    };
    home.file.".vst/RVXX v2.so".source = "${rvxx}/RVXX v2.so";
  };
}
