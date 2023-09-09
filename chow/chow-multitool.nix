{ stdenv
, fetchurl
, alsa-lib
, dpkg
, freetype
, lib
}:

stdenv.mkDerivation rec {
  pname = "ChowMultitool";
  version = "1.0.0";

  src = fetchurl {
    url = "https://github.com/Chowdhury-DSP/ChowMultiTool/releases/download/v1.0.0/ChowMultiTool-Linux-x64-${version}.deb";
    sha256 = "sha256-6dYEuoxcQ9V2G5xz6wUwrBMyJVkc7o48IsWEBrM9zTA=";
  };

  nativeBuildInputs = [ dpkg ];

  unpackCmd = ''
    mkdir -p root
    dpkg-deb -x $curSrc root
  '';

  dontBuild = true;
  dontWrapGApps = true; # we only want $gappsWrapperArgs here

  buildInputs = [
    alsa-lib
  #   at-spi2-atk
  #   cairo
    freetype
  #   gdk-pixbuf
  #   glib
  #   gnome2.pango
  #   gtk3
  #   harfbuzz
  #   libglvnd
  #   libjack2
  #   # libjpeg8 is required for converting jpeg's to colour palettes
  #   libjpeg
  #   libxcb
  #   libXcursor
  #   libX11
  #   libXtst
  #   libxkbcommon
  #   pipewire
  #   pulseaudio
    stdenv.cc.cc.lib
  #   xcbutil
  #   xcbutilwm
  #   zlib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/lv2 $out/lib/clap $out/lib/vst3

    cp usr/bin/ChowMultiTool $out/bin
    cp usr/lib/clap/ChowMultiTool.clap $out/lib/clap
    cp -r usr/lib/lv2/ChowMultiTool.lv2 $out/lib/lv2
    cp -r usr/lib/vst3/ChowMultiTool.vst3 $out/lib/vst3

    runHook postInstall
  '';

  postFixup =
  let
    libraryPath = "${lib.strings.makeLibraryPath buildInputs}";
  in
  ''
    # patchelf fails to set rpath on BitwigStudioEngine, so we use
    # the LD_LIBRARY_PATH way

    find $out | while IFS= read -r f; do
      patchelf --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" $f || true
      patchelf --set-rpath "${libraryPath}" $f || true
    done
  '';
}
