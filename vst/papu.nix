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
}:
let
  buildType = "Release";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "PAPU";
  version = "ec7ad348d53df3a7442d1a355ec620ef6068c0fa";

  src = fetchFromGitHub {
    owner = "FigBug";
    repo = finalAttrs.pname;
    rev = "${finalAttrs.version}";
    sha256 = "sha256-OUntEa7rSJIrvJHYN4iK8dZfOvygRiAuOwOFQkrwqZc=";
    fetchSubmodules = true;
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

  # Add recommended LTO flags, seems to decrease build time a bit, but for some
  # reason, the final linker steps still take forever in release builds
  postPatch = ''
    sed -i '159i juce::juce_recommended_lto_flags' CMakeLists.txt
  '';

  # We need a valid $HOME or juce_vst3_helper fails because it loads the plugin and the
  # plugin always creates a FilesystemWatcher on the config directory of the plugin
  preBuild = ''
    export HOME=$(pwd)/home
    mkdir -p $HOME
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
      cp -R ${finalAttrs.pname}_artefacts/${buildType}/VST3/* ${vst3path}
      cp -R ${finalAttrs.pname}_artefacts/${buildType}/LV2/* ${lv2path}
      cp -R ${finalAttrs.pname}_artefacts/${buildType}/Standalone/* ${binpath}

      runHook postInstall
    '';

  meta = with lib; {
    description = "VST / AU Gameboy PAPU emulation";
    homepage = "https://github.com/FigBug/PAPU";
    license = licenses.gpl2;
    platforms = platforms.linux;
    mainProgram = "PAPU";
    maintainers = with maintainers; [ polygon ];
  };
})
