{ self }:
{ pkgs, config, lib, ... }:

with lib;
let
  bwrap = "${pkgs.bubblewrap}/bin/bwrap";
in
{
  options.audio.audioenv.enable = mkEnableOption "Audio Environment";
  options.audio.audioenv.bwrap_args = mkOption {
    type = types.listOf types.str;
    default = [];
    description = "Additional arguments for bwrap";    
  };

  config = mkIf config.audio.audioenv.enable
  {
    home.packages = 
    let
      extra_args = concatStringsSep " " config.audio.audioenv.bwrap_args;
      wrapper = ''
        blacklist=(/nix /dev /proc /opt)
        declare -a auto_mounts
        for dir in /*; do
          if [[ -d "$dir" ]] && [[ ! "''${blacklist[@]}" =~ "$dir" ]]; then
            auto_mounts+=(--bind "$dir" "$dir")
          fi
        done
        cmd=(
          ${bwrap}
          --dev-bind /dev /dev
          --proc /proc
          --ro-bind /nix /nix
          "''${auto_mounts[@]}"
          ${extra_args}
        )
      '';
    in
    [ 
      (pkgs.writeShellApplication {
        name = "audioenv";
        
        text = wrapper + ''
          cmd+=("$@")
          exec "''${cmd[@]}"
        '';

        checkPhase = "";
      })      
    ];
  };
}
