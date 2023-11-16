{ alsa-lib
, cmake
, curl
, libepoxy
, fetchFromGitHub
, freetype
, gcc11
, gtk3
, lib
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
, libuuid
, libxkbcommon
, pcre
, pcre2
, pkg-config
, sqlite
, webkitgtk
, stdenv
}:
stdenv.mkDerivation rec {
  pname = "ChowMultiTool";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "Chowdhury-DSP";
    repo = "ChowMultiTool";
    rev = "v${version}";
    sha256 = "sha256-IRnuACsTjolnRh/FOZIdBuAjGdQC2rilLPJgjGZP+XY=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkg-config cmake ];

  buildInputs = [
    alsa-lib
    curl
    libepoxy
    freetype
    gtk3
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
    libuuid
    libxkbcommon
    pcre
    pcre2
    sqlite
    webkitgtk
  ];

  cmakeFlags = [
    "-DCMAKE_AR=${stdenv.cc.cc}/bin/gcc-ar"
    "-DCMAKE_RANLIB=${stdenv.cc.cc}/bin/gcc-ranlib"
    "-DCMAKE_NM=${stdenv.cc.cc}/bin/gcc-nm"
  ];

  cmakeBuildType = "Release";

  # LTO does not work for this plugin, disable it
  postPatch = ''
    sed -i -e '/juce::juce_recommended_lto_flags/d' modules/CMakeLists.txt
  '';

  installPhase = ''
    mkdir -p $out/lib/lv2 $out/lib/vst3 $out/bin $out/lib/clap
    cd ChowMultiTool_artefacts/${cmakeBuildType}
    cp -r LV2/ChowMultiTool.lv2 $out/lib/lv2
    cp -r VST3/ChowMultiTool.vst3 $out/lib/vst3
    cp -r CLAP/ChowMultiTool.clap $out/lib/clap
    cp Standalone/ChowMultiTool  $out/bin
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
    homepage = "https://github.com/Chowdhury-DSP/ChowMultiTool";
    description =
      "Multi-Tool Audio Plugin";
    license = with licenses; [ gpl3Only ];
    maintainers = with maintainers; [ polygon ];
    platforms = platforms.linux;
  };
}
