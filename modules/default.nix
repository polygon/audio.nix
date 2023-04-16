flake:
let
  imported_mods = [ ./audio.nix ];
in
{
  imports = map (m: import m flake) imported_mods;
}
