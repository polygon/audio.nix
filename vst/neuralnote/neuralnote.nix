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
, libonnxruntime-neuralnote
}:
let
  buildType = "Release";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "NeuralNote";
  version = "3320d4b856c51bb72ebb443ca526d779e6aa1b1a";

  src = fetchFromGitHub {
    owner = "polygon";
    repo = finalAttrs.pname;
    rev = "${finalAttrs.version}";
    sha256 = "sha256-HBhzrlpkOzwx/Xs+Q+DReNprmNh+zTOQ+/Fc3LJjofQ=";
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
  ]);

  # Remove LTO options, does not work just like that
  postPatch = ''
    sed -i -e '/juce::juce_recommended_lto_flags/d' CMakeLists.txt
    cd ThirdParty
    rm -rf onnxruntime || true
    mkdir onnxruntime
    cd onnxruntime
    tar xf ${libonnxruntime-neuralnote}/libonnxruntime-neuralnote.tar.gz
    mv model.with_runtime_opt.ort ../../Lib/ModelData/features_model.ort
    cd ../..
  '';

  cmakeBuildType = buildType;

  installPhase = let
    vst3path = "${placeholder "out"}/lib/vst3";
    binpath = "${placeholder "out"}/bin";
  in
  ''
    runHook preInstall

    mkdir -p ${vst3path}
    mkdir -p ${binpath}

    cp -R NeuralNote_artefacts/${buildType}/VST3/* ${vst3path}
    cp -R NeuralNote_artefacts/${buildType}/Standalone/* ${binpath}

    runHook postInstall
  '';

  meta = with lib; {
    description = "NeuralNote";
    homepage = "https://github.com/DamRsn/NeuralNote";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [ polygon ];
  };
})
