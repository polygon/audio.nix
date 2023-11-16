{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, cairo
, libxkbcommon
, xcbutilcursor
, xcbutilkeysyms
, xcbutil
, libXrandr
, libXinerama
, libXcursor
, alsa-lib
, libjack2
, lv2
}:

stdenv.mkDerivation rec {
  pname = "ChowCentaur";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "jatinchowdhury18";
    repo = "KlonCentaur";
    rev = "v${version}";
    sha256 = "0mrzlf4a6f25xd7z9xanpyq7ybb4al01dzpjsgi0jkmlmadyhc4h";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [
    cairo
    libxkbcommon
    xcbutilcursor
    xcbutilkeysyms
    xcbutil
    libXrandr
    libXinerama
    libXcursor
    alsa-lib
    libjack2
    lv2
  ];

  cmakeFlags = [
    "-DCMAKE_AR=${stdenv.cc.cc}/bin/gcc-ar"
    "-DCMAKE_RANLIB=${stdenv.cc.cc}/bin/gcc-ranlib"
    "-DCMAKE_NM=${stdenv.cc.cc}/bin/gcc-nm"
  ];

  installPhase = ''
    mkdir -p $out/lib/lv2 $out/lib/vst3 $out/bin
    cd ChowCentaur/ChowCentaur_artefacts/Release
    cp -r LV2/ChowCentaur.lv2 $out/lib/lv2
    cp -r VST3/ChowCentaur.vst3 $out/lib/vst3
    cp -r Standalone/ChowCentaur $out/bin
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
    description =
      "Digital emulation of the Klon Centaur guitar pedal using RNNs, Wave Digital Filters, and more";
    homepage = "https://github.com/jatinchowdhury18/KlonCentaur";
    license = licenses.bsd3;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ magnetophon ];
  };
}
