{ lib, stdenv, fetchurl, unzip, autoPatchelfHook, alsa-lib, xorg, curl, libGL, freetype }:
stdenv.mkDerivation rec {
  pname = "Atlas2";
  version = "2.3.4";

  src = fetchurl {
    url = "https://d11odam63kxzru.cloudfront.net/Atlas_2.3.4_Linux.zip";
    sha256 = "sha256-zyZArIOFbMt5Epc7xHK6NHrKCq7dwnPr6PR1eVe/bww=";
  };

  nativeBuildInputs = [
    unzip
    autoPatchelfHook
  ];

  buildInputs = [
    alsa-lib
    stdenv.cc.cc.lib
    curl
    libGL
    freetype
  ];

  unpackPhase = ''
    unzip ${src}
  '';

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib/vst
    mkdir -p $out/lib/vst3
    cp standalone/Atlas $out/bin/
    cp vst2/Atlas.so $out/lib/vst/
    cp -r vst3/Atlas.vst3 $out/lib/vst3/
  '';

  meta = with lib; {
    description = "Algonaut Atlas2";
    homepage = "https://algonaut.audio/";
    platforms = platforms.all;
    maintainers = with maintainers; [ polygon ];
  };
}
