# https://web.archive.org/web/20160316191703/http://thepiz.org/pizmidi/midiChordAnalyzer64.zip
{ writeShellScript, fetchzip }:
let
  mca = fetchzip {
    url =
      "https://web.archive.org/web/20160316191703/http://thepiz.org/pizmidi/midiChordAnalyzer64.zip";
    sha256 = "sha256-vae1TEg9V7S/z/g+xXAXqRkDHSSHj5tKLPsC7eUPsPs=";
  };
in writeShellScript "midichordanalyzer" ''
  echo "--------------------"
  echo "Copying DLL"
  echo "--------------------"
  mkdir -p "''${WINEPREFIX}/drive_c/Program Files/Common Files/VST2"
  cp ${mca}/midiChordAnalyzer.dll "''${WINEPREFIX}/drive_c/Program Files/Common Files/VST2/"
''
