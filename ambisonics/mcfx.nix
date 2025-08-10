{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, alsa-lib
, freetype
, webkitgtk_4_1
, curl
, jack2
, xorg
, libGL
, mesa
, fftw
, fftwFloat
, zita-convolver
# Configurable build options
, enableVST2 ? false
, enableVST3 ? true
, enableStandalone ? true
, enableLV2 ? false
, enableZitaConvolver ? true
, numChannels ? 64
, maxDelayTimeS ? "0.5"
}:
let
  buildType = "Release";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "mcfx";
  version = "0.6.3";

  src = fetchFromGitHub {
    owner = "kronihias";
    repo = "mcfx";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-zAQQTFSS6T4Ay1qYTdQf47pRXbqAGTc6jDtUKjChZso=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake pkg-config ];
  
  buildInputs = [
    alsa-lib
    freetype
    webkitgtk_4_1
    curl
    jack2
    xorg.libX11
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXext
    xorg.libXinerama
    xorg.xrandr
    xorg.libXrender
    libGL
    mesa
    fftw
    fftwFloat
  ] ++ lib.optionals enableZitaConvolver [
    zita-convolver
  ];
  
  # JUCE dlopens these, make sure they are in rpath
  NIX_LDFLAGS = toString ([
    "-lX11"
    "-lXext"
    "-lXcursor"
    "-lXinerama"
    "-lXrandr"
    "-lXrender"
    "-lXcomposite"
    "-lGL"
    "-lfftw3f"
  ] ++ lib.optionals enableZitaConvolver [
    "-lzita-convolver"
  ]);

  cmakeFlags = [
    "-DCMAKE_AR=${stdenv.cc.cc}/bin/gcc-ar"
    "-DCMAKE_RANLIB=${stdenv.cc.cc}/bin/gcc-ranlib"
    "-DCMAKE_NM=${stdenv.cc.cc}/bin/gcc-nm"
    "-DCMAKE_BUILD_TYPE=${buildType}"
    "-DBUILD_VST=${if enableVST2 then "TRUE" else "FALSE"}"
    "-DBUILD_VST3=${if enableVST3 then "TRUE" else "FALSE"}"
    "-DBUILD_LV2=${if enableLV2 then "TRUE" else "FALSE"}"
    "-DBUILD_STANDALONE=${if enableStandalone then "TRUE" else "FALSE"}"
    "-DNUM_CHANNELS=${toString numChannels}"
    "-DMAX_DELAYTIME_S=${maxDelayTimeS}"
    "-DJUCE_JACK=${if enableStandalone then "TRUE" else "FALSE"}"
    "-DJUCE_ALSA=${if enableStandalone then "TRUE" else "FALSE"}"
  ] ++ lib.optionals (stdenv.isLinux && enableZitaConvolver) [
    "-DWITH_ZITA_CONVOLVER=TRUE"
  ];

  cmakeBuildType = buildType;

  # Patch JUCE Jack implementation as per CMakeLists.txt
  postPatch = lib.optionalString enableStandalone ''
    if [ -f JUCE_patches/juce_linux_JackAudio.cpp.patch ]; then
      patch -p0 JUCE/modules/juce_audio_devices/native/juce_linux_JackAudio.cpp < JUCE_patches/juce_linux_JackAudio.cpp.patch || true
    fi
  '';

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
      # Install VST2 plugins  
      find . -name "*.so" -path "*/vst/*" -exec cp {} ${vstpath}/ \;
    ''}

    ${lib.optionalString enableLV2 ''
      # Install LV2 plugins
      find . -name "*.lv2" -type d -exec cp -R {} ${lv2path}/ \;
    ''}
    
    ${lib.optionalString enableStandalone ''
      # Install standalone applications - be more specific to avoid CMake artifacts
      find . -name "mcfx_*" -type f -executable -not -name "*.so" -not -path "*.vst3/*" -not -path "*.lv2/*" -exec cp {} ${binpath}/ \;
    ''}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Multichannel Audio Plug-in Suite for Ambisonic production";
    longDescription = ''
      mcfx is a suite of multichannel audio plug-ins, made for 
      production of Ambisonic content. The plug-ins are available 
      as VST, VST3, LV2 and standalone applications for OSX, Windows and Linux.
    '';
    homepage = "https://github.com/kronihias/mcfx";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ]; # Add your maintainer info here
  };
})