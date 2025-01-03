{ writeShellScript, fetchurl }:
let
  Voxengo_Span = fetchurl {
    url =
      "https://www.voxengo.com/files/VoxengoSPAN_322_Win32_64_VST_VST3_AAX_setup.exe";
    sha256 = "sha256-JeM4nVy+lbW0OrK6t/NQqcL5UALumBHHxoyfIGqW9VY=";
  };
in writeShellScript "voxengo_span" ''
  echo "--------------------"
  echo "Installing App"
  echo "--------------------"
  wine ${Voxengo_Span} /SP- /Silent /suppressmsgboxes
''
