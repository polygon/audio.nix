{ lib
, stdenv
, fetchFromGitHub
, fetchurl
, cmake
, pkg-config
, alsa-lib
, freetype
, webkitgtk
, curl
, xorg
, pcre2
, pcre
, gtk3
, libuuid
, libselinux
, libsepol
, libthai
, libdatrie
, libxkbcommon
, libepoxy
, libsysprof-capture
, sqlite
}:
let
  buildType = "Release";
  buildproxy = lib.mkBuildproxy ./proxy_content.nix;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "gRainbow";
  version = "v1.0.3";

  src = fetchFromGitHub {
    owner = "StrangeLoopsAudio";
    repo = finalAttrs.pname;
    rev = "${finalAttrs.version}";
    sha256 = "sha256-V8aMuSqKndisaBGpWIhotg8WR0zfJLItxF2dgzvvHmQ=";
    fetchSubmodules = true;
  };

  prePatch = ''
    source ${buildproxy}
  '';

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [
    freetype
    alsa-lib
    webkitgtk
    curl
    gtk3
    xorg.libX11
    xorg.libXdmcp
    xorg.libXtst
    pcre2
    pcre
    libuuid
    libselinux
    libsepol
    libthai
    libdatrie
    libxkbcommon
    libepoxy
    libsysprof-capture
    sqlite.dev
    buildproxy
  ];

  # JUCE dlopens these, make sure they are in rpath
  # Otherwise, segfault will happen
  NIX_LDFLAGS = (toString [
    "-lX11"
    "-lXext"
    "-lXcursor"
    "-lXinerama"
    "-lXrandr"
  ]);

  # Needed for LTO to work, currently unsure as to why
  cmakeFlags = [
    "-DCMAKE_AR=${stdenv.cc.cc}/bin/gcc-ar"
    "-DCMAKE_RANLIB=${stdenv.cc.cc}/bin/gcc-ranlib"
    "-DCMAKE_NM=${stdenv.cc.cc}/bin/gcc-nm"
  ];

  cmakeBuildType = buildType;

  postPatch = ''
    sed -i -e 's@JUCE_COPY_PLUGIN_AFTER_BUILD=1@JUCE_COPY_PLUGIN_AFTER_BUILD=0@' CMakeLists.txt
    sed -i -e 's@COPY_PLUGIN_AFTER_BUILD TRUE@COPY_PLUGIN_AFTER_BUILD FALSE@' CMakeLists.txt
  '';

  installPhase =
    let
      vst3path = "${placeholder "out"}/lib/vst3";
      lv2path = "${placeholder "out"}/lib/lv2";
      binpath = "${placeholder "out"}/bin";
    in
    ''
      runHook preInstall

      mkdir -p ${vst3path}
      mkdir -p ${binpath}
      mkdir -p ${lv2path}
      cp -R gRainbow_artefacts/Release/VST3/* ${vst3path}
      cp -R gRainbow_artefacts/Release/LV2/* ${lv2path}
      cp -R gRainbow_artefacts/Release/Standalone/* ${binpath}

      runHook postInstall
    '';

  meta = with lib; {
    description = "An open-source, cross platform synthesizer that uses pitch detection to choose candidates for granular synthesis or sampling";
    homepage = "https://bboettcher3.github.io/grainbow";
    license = licenses.gpl3;
    platforms = platforms.linux;
    mainProgram = "gRainbow";
    maintainers = with maintainers; [ polygon ];
  };
})
