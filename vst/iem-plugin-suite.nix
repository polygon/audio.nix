{ lib
, stdenv
, fetchFromGitLab
, cmake
, pkg-config
, alsa-lib
, freetype
, webkitgtk_4_1
, curl
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
  pname = "iem-plugin-suite";
  version = "1.15.0";

  src = fetchFromGitLab {
    domain = "git.iem.at";
    owner = "audioplugins";
    repo = "IEMPluginSuite";
    rev = "v${finalAttrs.version}";
    sha256 = ""; # You'll need to add the correct hash after first build attempt
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [
    freetype
    alsa-lib
    webkitgtk_4_1
    curl
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

  # Needed for LTO to work
  cmakeFlags = [
    "-DCMAKE_AR=${stdenv.cc.cc}/bin/gcc-ar"
    "-DCMAKE_RANLIB=${stdenv.cc.cc}/bin/gcc-ranlib"
    "-DCMAKE_NM=${stdenv.cc.cc}/bin/gcc-nm"
    "-DCMAKE_BUILD_TYPE=${buildType}"
  ];

  cmakeBuildType = buildType;

  installPhase = let
    vst3path = "${placeholder "out"}/lib/vst3";
    vstpath = "${placeholder "out"}/lib/vst";
    binpath = "${placeholder "out"}/bin";
  in
  ''
    runHook preInstall

    mkdir -p ${vst3path}
    mkdir -p ${vstpath}
    mkdir -p ${binpath}

    # Install VST3 plugins
    find . -name "*.vst3" -type d -exec cp -R {} ${vst3path}/ \;
    
    # Install VST2 plugins (if built)
    find . -name "*.so" -path "*/VST/*" -exec cp {} ${vstpath}/ \;
    
    # Install standalone applications (if any)
    find . -name "*" -type f -executable -not -name "*.so" -not -name "*.vst3" -exec cp {} ${binpath}/ \; 2>/dev/null || true

    runHook postInstall
  '';

  meta = with lib; {
    description = "IEM Plugin Suite for production of Ambisonic content";
    longDescription = ''
      The IEM Plugin Suite is a comprehensive collection of audio plugins for 
      Ambisonic and multichannel audio processing, developed by the Institute 
      of Electronic Music and Acoustics (IEM) in Graz, Austria.
    '';
    homepage = "https://git.iem.at/audioplugins/IEMPluginSuite";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ]; # Add your maintainer info here
  };
})