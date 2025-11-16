{ lib, stdenv, fetchurl, unzip, autoPatchelfHook, writeShellScript
, steam-run-free, glib, alsa-lib, xorg, curl, openssl, libGL, freetype
, glibc_multi, patchelf, coreutils }:
stdenv.mkDerivation rec {
  pname = "Amp Locker";
  version = "1.0.9";

  src = fetchurl {
    url =
      "https://audioassaultdownloads.s3.amazonaws.com/AmpLocker/AmpLocker109/AmpLockerLinux.zip";
    sha256 = "sha256-9LqMGBtFGgz9CPFUn4ShLYiN21wTBRWDgYOsmdDF478=";
  };

  nativeBuildInputs = [ unzip patchelf coreutils ];

  buildInputs = [
    steam-run-free
    alsa-lib
    xorg.libX11
    curl
    openssl
    libGL
    freetype
    glibc_multi
  ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;
  dontUnpack = true;

  installPhase = ''
        unzip -q "$src" -d .
        ls -la
        mkdir -p $out
        mkdir -p $out/bin
        mkdir -p $out/lib/vst3
        mkdir -p $out/"Audio Assault"
        cp -r "Amp Locker Standalone" $out/bin/".Amp_Locker_Standalone_unwrapped"
        cp -r "Amp Locker.vst3" $out/lib/vst3/
        cp -r "AmpLockerData" $out/"Audio Assault"/

        # Wrap the standalone with steam-run, it seems to segfault otherwise trying to access FHS paths
        cat > $out/bin/Amp_Locker_Standalone <<'EOF'
    #!/usr/bin/env sh
    HERE="$(dirname "$0")"
    ${steam-run-free}/bin/steam-run "''${HERE}/.Amp_Locker_Standalone_unwrapped" "$@"
    EOF
        chmod +x $out/bin/Amp_Locker_Standalone
  '';

  preFixup = let
    libraryPath = lib.makeLibraryPath [
      alsa-lib
      xorg.libX11
      stdenv.cc.cc.lib
      curl
      openssl
      libGL
      freetype
      glibc_multi
    ];
  in ''
    patchelf --add-rpath ${libraryPath} $out/lib/vst3/"Amp Locker.vst3"/Contents/x86_64-linux/"Amp Locker.so"
  '';

  meta = with lib; {
    description = "AudioAssault Amp Locker";
    homepage = "https://audioassault.mx/";
    platforms = platforms.all;
    maintainers = with maintainers; [ polygon ];
    mainProgram = "Amp_Locker_Standalone";
    license = licenses.unfree;
  };
}
