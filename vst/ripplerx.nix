{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, alsa-lib
, freetype
, webkitgtk_4_1
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
, lerc
}:
let
  buildType = "Release";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "ripplerx";
  version = "v1.4.1";

  src = fetchFromGitHub {
    owner = "tiagolr";
    repo = finalAttrs.pname;
    rev = "${finalAttrs.version}";
    sha256 = "sha256-MlUDqUpPyrh/Wdt7KD2plKdTmkiqDSYqA/eBGDWBhGU=";
    fetchSubmodules = true; # JUCE plugins usually pull JUCE and other deps via submodules
  };

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [
    freetype
    alsa-lib
    webkitgtk_4_1
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
    lerc.dev
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
    sed -i -e 's@COPY_PLUGIN_AFTER_BUILD TRUE@COPY_PLUGIN_AFTER_BUILD FALSE@' CMakeLists.txt
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
    in
    ''
      runHook preInstall

      mkdir -p ${vst3path}
      mkdir -p ${lv2path}
      cp -R RipplerX_artefacts/Release/VST3/* ${vst3path}
      cp -R RipplerX_artefacts/Release/LV2/* ${lv2path}

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
