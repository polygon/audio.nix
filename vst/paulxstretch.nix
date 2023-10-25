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
    #pcre2
    #pcre
    #libuuid
    #libselinux
    #libsepol
    #libthai
    #libdatrie
    #xorg.libXdmcp
    #libxkbcommon
    #libepoxy
    #xorg.libXtst
    #libsysprof-capture
    #sqlite.dev
    #libpsl    
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

  # Remove LTO options, does not work just like that
  postPatch = ''
    sed -i -e '/juce::juce_recommended_lto_flags/d' CMakeLists.txt
  '';

  installPhase = let
    vst3path = "${placeholder "out"}/lib/vst3";
    binpath = "${placeholder "out"}/bin";
    clappath = "${placeholder "out"}/clap";
  in
  ''
    runHook preInstall

    mkdir -p ${vst3path}
    mkdir -p ${binpath}
    mkdir -p ${clappath}

    cp -R PaulXStretch_artefacts/Release/VST3/* ${vst3path}
    cp -R PaulXStretch_artefacts/Release/Standalone/* ${binpath}
    cp -R PaulXStretch_artefacts/Release/CLAP/* ${clappath}

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
