{ lib, stdenv, requireFile, unzip, autoPatchelfHook, buildFHSUserEnv, writeShellScript, alsaLib, xorg, curl, libGL, freetype }:
stdenv.mkDerivation rec {
  pname = "RVXX";
  version = "2021.02";

  src = requireFile rec {
    name = "RVXX+v2+Installers+Feb_26_2021.zip";
    message = ''
      This Nix expression requires the RVXX plugin download is
      already part of the store. Please download your purchased
      copy and place the ${name} file into the Nix Store with:

      "nix-prefetch-url file://${name}"
    '';
    sha256 = "1asgldqvsvvy0nyyyp0i2hyd94v84h6bfdcrax1bkzb0iw8gsx1m";
  };

  unpackPhase = ''
    unzip ${src}
  '';

  nativeBuildInputs = [
    unzip
    autoPatchelfHook
  ];

  buildInputs = [
    alsaLib
    xorg.libX11
    stdenv.cc.cc.lib
    (curl.override { gnutlsSupport = true; opensslSupport = false; })
    libGL
    freetype
  ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    mkdir -p $out
    cd RVXX\ v2\ Linux\ /InstallerData/RVXX/
    cp -r * $out
  '';

  meta = with lib; {
    description = "AudioAssault RVXX";
    homepage = "https://audioassault.mx/products/rvxx";
    license = licenses.cc-by-40;
    platforms = platforms.all;
    maintainers = with maintainers; [ polygon ];
  };
}