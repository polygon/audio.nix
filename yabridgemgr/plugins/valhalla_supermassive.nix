{ writeShellScript, fetchzip }:
let
  Valhalla = fetchzip {
    url =
      "https://valhallaproduction.s3.us-west-2.amazonaws.com/supermassive/ValhallaSupermassiveWin_V3_0_0b3.zip";
    sha256 = "sha256-BU7Neha2idSov2m1m8bgnBEV+iqW+Hovs9rsVTBjesk=";
  };
in writeShellScript "valhalla" ''
  echo "--------------------"
  echo "Installing App"
  echo "--------------------"
  wine ${Valhalla}/ValhallaSupermassiveWin_V3_0_0b3.exe /SP- /Silent /suppressmsgboxes
''
