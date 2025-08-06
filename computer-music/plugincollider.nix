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
, jack2
, libsndfile
, boost
, fftw
, fftwFloat
, enableDynamicPlugins ? false
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "plugincollider";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "simonvanderveldt";
    repo = "PluginCollider";
    rev = "v${finalAttrs.version}";
    sha256 = lib.fakeSha256;
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake pkg-config ];
  
  buildInputs = [
    freetype
    alsa-lib
    jack2
    xorg.libX11
    xorg.libXext
    xorg.libXinerama
    xorg.xrandr
    xorg.libXcursor
    xorg.libXrender
    libsndfile
    boost
    fftw
    fftwFloat
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DSC_DYNAMIC_PLUGINS=${if enableDynamicPlugins then "ON" else "OFF"}"
  ];

  # Let CMake handle most of the configuration automatically
  postPatch = ''
    # Only patch if absolutely necessary - let the build system work as designed
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/vst3
    find . -name "PluginCollider.vst3" -type d -exec cp -R {} $out/lib/vst3/ \;

    runHook postInstall
  '';

  enableParallelBuilding = false;

  meta = with lib; {
    description = "SuperCollider as a VST3 plugin using JUCE";
    homepage = "https://github.com/simonvanderveldt/PluginCollider";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
})