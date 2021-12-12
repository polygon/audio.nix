{ self }:
{ pkgs, config, lib, ... }:

with lib;
let
  shittyKit = self.packages.${pkgs.system}.drumkits.shittyKit;
in
{
  options.audio.drumkits.shittyKit.enable = mkEnableOption "Shitty Kit";
  options.audio.drumkits.path = mkOption {
      type = types.str;
      default = "audio/drumkits";
      description = "Path prefix to link drumkits";
  };

  config = mkIf config.audio.drumkits.shittyKit.enable
  {
    home.packages = [ shittyKit ];
    home.file."${config.audio.drumkits.path}/ShittyKit".source = "${shittyKit}";
  };
}
