{ alsa-lib
, at-spi2-core
, brotli
, cmake
, curl
, dbus
, libepoxy
, fetchFromGitHub
, freeglut
, freetype
, gtk2-x11
, lib
, libGL
, libXcursor
, libXdmcp
, libXext
, libXinerama
, libXrandr
, libXtst
, libdatrie
, libjack2
, libpsl
, libselinux
, libsepol
, libsysprof-capture
, libthai
, libxkbcommon
, lv2
, pcre
, pcre2
, pkg-config
, python3
, sqlite
, stdenv
, util-linuxMinimal
, webkitgtk
}:

stdenv.mkDerivation rec {
  pname = "ChowKick";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "Chowdhury-DSP";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-YYcNiJGGw21aVY03tyQLu3wHCJhxYiDNJZ+LWNbQdj4=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
    cmake
  ];
  buildInputs = [
    alsa-lib
    at-spi2-core
    brotli
    curl
    dbus
    libepoxy
    freeglut
    freetype
    gtk2-x11
    libGL
    libXcursor
    libXdmcp
    libXext
    libXinerama
    libXrandr
    libXtst
    libdatrie
    libjack2
    libpsl
    libselinux
    libsepol
    libsysprof-capture
    libthai
    libxkbcommon
    lv2
    pcre
    pcre2
    python3
    sqlite
    util-linuxMinimal
    webkitgtk
  ];

  cmakeFlags = [
    "-DCMAKE_AR=${stdenv.cc.cc}/bin/gcc-ar"
    "-DCMAKE_RANLIB=${stdenv.cc.cc}/bin/gcc-ranlib"
  ];

  installPhase = ''
    mkdir -p $out/lib/lv2 $out/lib/vst3 $out/lib/clap $out/bin
    cp -r ChowKick_artefacts/Release/VST3/ChowKick.vst3 $out/lib/vst3
    cp -r ChowKick_artefacts/Release/LV2/ChowKick.lv2 $out/lib/lv2
    cp ChowKick_artefacts/Release/CLAP/ChowKick.clap $out/lib/clap
    cp ChowKick_artefacts/Release/Standalone/ChowKick  $out/bin
    cp src/headless/ChowKick_headless_artefacts/Release/ChowKick_headless $out/bin
  '';

  # JUCE dlopens these, make sure they are in rpath
  # Otherwise, segfault will happen
  NIX_LDFLAGS = (toString [
    "-lX11"
    "-lXext"
    "-lXcursor"
    "-lXinerama"
    "-lXrandr"
  ]);

  meta = with lib; {
    homepage = "https://github.com/Chowdhury-DSP/ChowKick";
    description = "Kick synthesizer based on old-school drum machine circuits";
    license = with licenses; [ bsd3 ];
    maintainers = with maintainers; [ magnetophon ];
    platforms = platforms.linux;
  };
}
