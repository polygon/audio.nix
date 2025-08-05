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
, eigen
# Configurable build options
, enableVST ? true
, enableStandalone ? false
, enableLV2 ? false
, enableZitaConvolver ? false
, enableAdvancedControl ? true
, enableOSC ? true
, ambiOrder ? 7
, numOutputsDecoder ? 64
, numFilters ? 8
, numFiltersVmic ? 8
}:
let
  buildType = "Release";
  # Ensure at least one format is enabled
  hasAnyFormat = enableVST || enableStandalone || enableLV2;
in
assert lib.assertMsg hasAnyFormat "At least one plugin format must be enabled";
stdenv.mkDerivation (finalAttrs: {
  pname = "ambix";
  version = "0.2.10";

  src = fetchFromGitHub {
    owner = "kronihias";
    repo = "ambix";
    rev = "v${finalAttrs.version}";
    sha256 = ""; # You'll need to add the correct hash after first build attempt
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
    eigen
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
    "-DBUILD_VST=${if enableVST then "TRUE" else "FALSE"}"
    "-DBUILD_LV2=${if enableLV2 then "TRUE" else "FALSE"}"
    "-DBUILD_STANDALONE=${if enableStandalone then "TRUE" else "FALSE"}"
    "-DWITH_ADVANCED_CONTROL=${if enableAdvancedControl then "TRUE" else "FALSE"}"
    "-DWITH_OSC=${if enableOSC then "TRUE" else "FALSE"}"
    "-DAMBI_ORDER=${toString ambiOrder}"
    "-DNUM_OUTPUTS_DECODER=${toString numOutputsDecoder}"
    "-DNUM_FILTERS=${toString numFilters}"
    "-DNUM_FILTERS_VMIC=${toString numFiltersVmic}"
  ] ++ lib.optionals (stdenv.isLinux && enableZitaConvolver) [
    "-DWITH_ZITA_CONVOLVER=TRUE"
  ];

  cmakeBuildType = buildType;

  installPhase = let
    vstpath = "${placeholder "out"}/lib/vst";
    lv2path = "${placeholder "out"}/lib/lv2";
    binpath = "${placeholder "out"}/bin";
  in
  ''
    runHook preInstall

    ${lib.optionalString enableVST "mkdir -p ${vstpath}"}
    ${lib.optionalString enableLV2 "mkdir -p ${lv2path}"}
    ${lib.optionalString enableStandalone "mkdir -p ${binpath}"}

    ${lib.optionalString enableVST ''
      # Install VST plugins from order-specific directory
      find . -name "*.so" -path "*/vst_o${toString ambiOrder}/*" -exec cp {} ${vstpath}/ \;
    ''}

    ${lib.optionalString enableLV2 ''
      # Install LV2 plugins from order-specific directory
      find . -name "*.lv2" -path "*/lv2_o${toString ambiOrder}/*" -type d -exec cp -R {} ${lv2path}/ \;
    ''}
    
    ${lib.optionalString enableStandalone ''
      # Install standalone applications - be more specific to avoid CMake artifacts
      find . -name "ambix_*" -type f -executable -not -name "*.so" -not -path "*.lv2/*" -not -name "CMake*" -exec cp {} ${binpath}/ \;
    ''}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Ambisonic plug-in suite with variable order for production, analysis and playback";
    longDescription = ''
      The ambix plug-in suite handles Ambisonic audio up to high orders and 
      is designed for content creation, analysis and playback. The tools 
      are available as VST2, LV2 plug-ins and standalone applications.
      
      This package builds with Ambisonic order ${toString ambiOrder}.
    '';
    homepage = "https://github.com/kronihias/ambix";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ]; # Add your maintainer info here
  };
})