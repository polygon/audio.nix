{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, libGL
, libX11
, SDL2
, dbus
, alsa-lib
, pulseaudio
, python3
, xorg
}:
let
  buildType = "Release";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "aida-x";
  version = "41eb988f5e0fd2c20a598060f65a853cf0eb9e10";

  src = fetchFromGitHub {
    owner = "AidaDSP";
    repo = "AIDA-X";
    rev = "${finalAttrs.version}";
    sha256 = "sha256-2CYpxLC+Ap01PxZWLNAVgA39Zbl0Obtg85vydSl6ZQ0=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake pkg-config python3 ];
  buildInputs = [
    libGL
    libX11
    SDL2
    dbus
    alsa-lib
    pulseaudio
    xorg.libX11
    xorg.libX11.dev
    xorg.libXext
    xorg.libXi
    xorg.libXrandr
    xorg.libXcursor
    xorg.libXScrnSaver
    xorg.libXfixes
    xorg.libxcb    
  ];

  NIX_LDFLAGS = (toString [
    "-lxcb"
  ]);

  cmakeBuildType = buildType;

  installPhase =
    let
      vst3path = "${placeholder "out"}/lib/vst3";
      lv2path = "${placeholder "out"}/lib/lv2";
      clappath = "${placeholder "out"}/lib/clap";
      binpath = "${placeholder "out"}/bin";
    in
    ''
      runHook preInstall

      mkdir -p ${vst3path}
      mkdir -p ${binpath}
      mkdir -p ${lv2path}
      mkdir -p ${clappath}
      cp bin/AIDA-X ${binpath}
      cp bin/AIDA-X.clap ${clappath}
      cp -R bin/AIDA-X.lv2 ${lv2path}
      cp -R bin/AIDA-X.vst3 ${vst3path}

      runHook postInstall
    '';

  postPatch = ''
    sed -i -e 's@/usr/bin/env python3@${python3}/bin/python3@' modules/dpf/utils/res2c.py
    sed -i -e 's@/usr/bin/env python3@${python3}/bin/python3@' modules/dpf/utils/png2rgba.py
  '';

  meta = with lib; {
    description = "Amp Model Player leveraging AI";
    homepage = "https://aida-x.cc/";
    license = licenses.gpl3;
    platforms = platforms.linux;
    mainProgram = "AIDA-X";
    maintainers = with maintainers; [ polygon ];
  };
})
