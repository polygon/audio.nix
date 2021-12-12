{ lib, stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "shittyKit";
  version = "1.2";

  src = fetchzip {
    url = "https://drumgizmo.org/kits/ShittyKit/ShittyKit1_2.zip";
    sha256 = "sha256-1xDqWv6QsHX78bnFPCcVFiAL1clAcdIeTZCO9xVXwSE=";
  };

  nativeBuildInputs = [

  ];

  buildInputs = [

  ];

  dontConfigure = true;
  dontBuild = true;
  dontPatchELF = true;
  dontStrip = true;

  installPhase = ''
    mkdir -p $out
    cp -r * $out
  '';

  meta = with lib; {
    description = "ShittyKit 1.2 for DrumGizmo";
    homepage = "https://drumgizmo.org/wiki/doku.php?id=kits:shittykit";
    license = licenses.cc-by-40;
    platforms = platforms.all;
    maintainers = with maintainers; [ polygon ];
  };
}
