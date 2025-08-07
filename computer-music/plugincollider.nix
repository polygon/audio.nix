{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, alsa-lib
, freetype
, fontconfig
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
    owner = "asb2m10";
    repo = "plugincollider";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-vnTwoQJeul5j9f39WQBaayxTGWhF1KxNWJsBTSI3MSk=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake pkg-config ];
  
  buildInputs = [
    freetype
    fontconfig  # Add this for fontconfig/fontconfig.h
    alsa-lib
    jack2
    xorg.libX11
    xorg.libXext
    xorg.libXinerama
    xorg.libXrandr  # This provides the headers (X11/extensions/Xrandr.h)
    xorg.libXcursor
    xorg.libXrender
    libsndfile
    boost
    fftw
    fftwFloat
  ];

  # Patch to disable plugin copying
  postPatch = ''
    sed -i 's/COPY_PLUGIN_AFTER_BUILD TRUE/COPY_PLUGIN_AFTER_BUILD FALSE/g' CMakeLists.txt
  '';

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DSC_DYNAMIC_PLUGINS=${if enableDynamicPlugins then "ON" else "OFF"}"
    "-DCMAKE_VERBOSE_MAKEFILE=ON"
    # Fix LTO issues
    "-DCMAKE_CXX_FLAGS=-fno-lto"
    "-DCMAKE_C_FLAGS=-fno-lto"
  ];

  # Add environment variables to help with linking
  preBuild = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -fno-lto"
    export NIX_LDFLAGS="$NIX_LDFLAGS -fno-lto"
  '';

  installPhase = ''
    runHook preInstall

    # Install VST3 plugin
    mkdir -p $out/lib/vst3
    find . -name "PluginCollider.vst3" -type d -exec cp -R {} $out/lib/vst3/ \;
    
    # Verify the plugin was built and copied
    if [ ! -d "$out/lib/vst3/PluginCollider.vst3" ]; then
      echo "ERROR: VST3 plugin not found after build"
      find . -name "*.vst3" -type d || echo "No VST3 files found"
      exit 1
    fi

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