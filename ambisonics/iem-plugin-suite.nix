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
, fftw
, fftwFloat
, libGL
, libglvnd
, util-linux
# Configurable build options
, enableStandalone ? true
, enableVST3 ? true
, enableVST2 ? false
, enableLV2 ? false
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
    sha256 = "sha256-JYe09sSG6cbwpBF8LEfsHDC+v9RZCr7VW1sgTYHPEO0=";
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
    # Add missing dependencies based on RPM list
    fftw
    fftwFloat  # This provides libfftw3f
    libGL
    libglvnd
    util-linux
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
    "-lfftw3f"
    "-lfftw3"
    "-lGL"
  ]);

  # Needed for LTO to work
  cmakeFlags = [
    "-DCMAKE_AR=${stdenv.cc.cc}/bin/gcc-ar"
    "-DCMAKE_RANLIB=${stdenv.cc.cc}/bin/gcc-ranlib"
    "-DCMAKE_NM=${stdenv.cc.cc}/bin/gcc-nm"
    "-DCMAKE_BUILD_TYPE=${buildType}"
    "-DIEM_BUILD_VST2=${if enableVST2 then "ON" else "OFF"}"
    "-DIEM_BUILD_VST3=${if enableVST3 then "ON" else "OFF"}"
    "-DIEM_BUILD_LV2=${if enableLV2 then "ON" else "OFF"}"
    "-DIEM_BUILD_STANDALONE=${if enableStandalone then "ON" else "OFF"}"
    "-DIEM_POST_BUILD_INSTALL=NO"  # Disable automatic copying
  ];

  cmakeBuildType = buildType;

  installPhase = let
    vst3path = "${placeholder "out"}/lib/vst3";
    vstpath = "${placeholder "out"}/lib/vst";
    lv2path = "${placeholder "out"}/lib/lv2";
    binpath = "${placeholder "out"}/bin";
  in
  ''
    runHook preInstall

    ${lib.optionalString enableVST3 "mkdir -p ${vst3path}"}
    ${lib.optionalString enableVST2 "mkdir -p ${vstpath}"}
    ${lib.optionalString enableLV2 "mkdir -p ${lv2path}"}
    ${lib.optionalString enableStandalone "mkdir -p ${binpath}"}

    ${lib.optionalString enableVST3 ''
      # Install VST3 plugins
      find . -name "*.vst3" -type d -exec cp -R {} ${vst3path}/ \;
    ''}
    
    ${lib.optionalString enableVST2 ''
      # Install VST2 plugins (if built)
      find . -name "*.so" -path "*/VST/*" -exec cp {} ${vstpath}/ \;
    ''}

    ${lib.optionalString enableLV2 ''
      # Install LV2 plugins (if built)
      find . -name "*.lv2" -type d -exec cp -R {} ${lv2path}/ \;
    ''}
    
    ${lib.optionalString enableStandalone ''
      # Install standalone applications (if any)
      find . -name "*" -type f -executable -not -name "*.so" -not -name "*.vst3" -not -name "*.lv2" -exec cp {} ${binpath}/ \; 2>/dev/null || true
    ''}

    runHook postInstall
  '';

  meta = with lib; {
    description = "IEM Plugin Suite for Ambisonic production";
    longDescription = ''
      The IEM Plug-in Suite is a free and Open-Source audio plug-in suite 
      including Ambisonic plug-ins up to 7th order 
      created by staff and students of the Institute of Electronic Music and Acoustics.
    '';
    homepage = "https://git.iem.at/audioplugins/IEMPluginSuite";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ]; # Add your maintainer info here
  };
})