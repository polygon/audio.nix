{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, alsa-lib
, freetype
, webkitgtk
, curl
, fftwFloat
, jack2
, xorg
, pcre2
, pcre
, libuuid
, libselinux
, libsepol
, libthai
, libdatrie
, libxkbcommon
, libepoxy
, libsysprof-capture
, sqlite
, libpsl
}:
let
  buildType = "Release";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "paulxstretch";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "essej";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-Oen9W7frt7l1m9YVJCFSIDKXdmj8tWrYx68+V2Mozt0=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [
    freetype
    alsa-lib
    webkitgtk
    curl
    fftwFloat
    jack2
    xorg.libX11
    xorg.libXext
    xorg.libXinerama
    xorg.xrandr
    xorg.libXcursor
    xorg.libXfixes
    xorg.libXrender
    xorg.libXScrnSaver
  ];
  
  # JUCE dlopens these, make sure they are in rpath
  # Otherwise, segfault will happen
  NIX_LDFLAGS = (toString [
    "-lX11"
    "-lXext"
    "-lXcursor"
    "-lXinerama"
    "-lXrandr"
    "-lXfixes"
    "-lXrender"
    "-lXss"
  ]);

  # Needed for LTO to work, currently unsure as to why
  cmakeFlags = [
    "-DCMAKE_AR=${stdenv.cc.cc}/bin/gcc-ar"
    "-DCMAKE_RANLIB=${stdenv.cc.cc}/bin/gcc-ranlib"
    "-DCMAKE_NM=${stdenv.cc.cc}/bin/gcc-nm"
  ];

  cmakeBuildType = buildType;

  installPhase = let
    vst3path = "${placeholder "out"}/lib/vst3";
    binpath = "${placeholder "out"}/bin";
    clappath = "${placeholder "out"}/lib/clap";
  in
  ''
    runHook preInstall

    mkdir -p ${vst3path}
    mkdir -p ${binpath}
    mkdir -p ${clappath}

    cp -R PaulXStretch_artefacts/${buildType}/VST3/* ${vst3path}
    cp -R PaulXStretch_artefacts/${buildType}/Standalone/* ${binpath}
    cp -R PaulXStretch_artefacts/${buildType}/CLAP/* ${clappath}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Extreme timestretch plugin";
    homepage = "https://sonosaurus.com/paulxstretch/";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ polygon ];
  };
})
