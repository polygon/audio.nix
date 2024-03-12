# Template to build a JUCE plugin, copy and follow the guide
{ lib
, stdenv
, fetchFromGitHub
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
, jack2
, libuuid
, libselinux
, libsepol
, libthai
, libdatrie
, libxkbcommon
, libepoxy
, libsysprof-capture
, libpsl
, sqlite
}:
let
  buildType = "Release";
in
stdenv.mkDerivation (finalAttrs: {
  # TODO: Set name and version
  pname = "SETME";
  version = "v1.0.0;";

  src = fetchFromGitHub {
    # TODO: Set repository information
    owner = "SETME";
    repo = finalAttrs.pname;
    rev = "${finalAttrs.version}";
    sha256 = "";
    fetchSubmodules = true; # JUCE plugins usually pull JUCE and other deps via submodules
  };

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [
    freetype
    alsa-lib
    webkitgtk
    curl
    gtk3
    jack2
    xorg.libX11
    xorg.libXext
    xorg.libXinerama
    xorg.xrandr
    xorg.libXcursor
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
    libpsl
    libsysprof-capture
    sqlite.dev
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

  # TODO: Do your, e.g. sed-based, source patching here
  postPatch = ''
  '';

  # TODO: Adjust this script, ideally doing an out of nix build for reference
  #       You may require a previous "cd" depending on where you "end up" in the
  #       build, hence the `pwd` and `ls` at the start which should be removed
  #       Also, the "finalAttrs.pname" usage below might not work and could be
  #       replaced with the actual paths
  installPhase =
    let
      vst3path = "${placeholder "out"}/lib/vst3";
      lv2path = "${placeholder "out"}/lib/lv2";
      clappath = "${placeholder "out"}/lib/clap";
      binpath = "${placeholder "out"}/bin";
    in
    ''
      runHook preInstall

      echo "In install phase, pwd: $(pwd)"
      echo "Contents: "
      ls -la

      mkdir -p ${vst3path}
      mkdir -p ${binpath}
      mkdir -p ${lv2path}
      mkdir -p ${clappath}
      cp -R ${finalAttrs.pname}_artefacts/Release/VST3/* ${vst3path}
      cp -R ${finalAttrs.pname}_artefacts/Release/LV2/* ${lv2path}
      cp -R ${finalAttrs.pname}_artefacts/Release/CLAP/* ${clappath}
      cp -R ${finalAttrs.pname}_artefacts/Release/Standalone/* ${binpath}

      runHook postInstall
    '';

  meta = with lib; {
    description = "";
    homepage = "";
    license = licenses.gpl3;
    platforms = platforms.linux;
    mainProgram = "";
    maintainers = with maintainers; [ polygon ];
  };
})
