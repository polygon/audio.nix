{
  lib
, stdenv
, requireFile
, unzip
, autoPatchelfHook
, alsaLib
, xorg
, curlWithGnuTls
, libGL
, freetype
, glibc
, patchelf
, bsdiff
, coreutils
}:
stdenv.mkDerivation rec {
  pname = "Amp Locker";
  version = "1.0.5";

  src = requireFile rec {
    name = "Amp+Locker+Linux.zip";
    message = ''
      This Nix expression requires the ${pname} plugin download is
      already part of the store. Please download your purchased
      copy and place the ${name} file into the Nix Store with:

      "nix store add-file ${name}"
    '';
    # Created using nix hash file Amp+Locker+Linux.zip
    sha256 = "sha256-408l/iSIYh67ZIJmq53DwTi1KyL5HkxcmFgzlEjEyUk=";
  };

  unpackPhase = ''
    unzip ${src}
  '';

  nativeBuildInputs = [
    unzip
    patchelf
    bsdiff
    coreutils
  ];

  buildInputs = [

  ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    mkdir -p $out
    mkdir -p $out/bin
    mkdir -p $out/lib/vst3
    mkdir -p $out/"Audio Assault"
    cp "Amp Locker Standalone" $out/bin/
    cp -r "Amp Locker.vst3" $out/lib/vst3/
    cp -r "AmpLockerData" $out/"Audio Assault"/
  '';

  preFixup = let
    libraryPath = lib.makeLibraryPath [
      alsaLib
      xorg.libX11
      stdenv.cc.cc.lib
      curlWithGnuTls
      libGL
      freetype
      glibc
    ];
    new_path_address_so = "0x804610";
    new_path_address_vst3 = "0xa55170";
    new_path_length = "216";  # Path will be truncated here should it somehow be longer, but zero-terminator will not be overwritten
    standalone_patch = ./standalone.patch;
    vst3_patch = ./vst3.patch;
  in
  ''
    # Patch standalone binary to fetch path to base-dir of assets from different and longer string
    # into which we will then inject the path of the current result directory
    bspatch $out/bin/"Amp Locker Standalone" $out/patched ${standalone_patch}
    mv -f $out/patched $out/bin/"Amp Locker Standalone"

    # Now, inject the nix store path into the binary
    echo -n -e "$out\x00" | dd of=$out/bin/"Amp Locker Standalone" conv=notrunc bs=1 seek=$((${new_path_address_so})) count=${new_path_length}
    chmod +x $out/bin/"Amp Locker Standalone"

    # Patch VST3 to fetch path to base-dir of assets from different and longer string
    # into which we will then inject the path of the current result directory
    bspatch $out/lib/vst3/"Amp Locker.vst3"/Contents/x86_64-linux/"Amp Locker.so" $out/patched ${vst3_patch}
    mv -f $out/patched $out/lib/vst3/"Amp Locker.vst3"/Contents/x86_64-linux/"Amp Locker.so"

    # Now, inject the nix store path into the binary
    echo -n -e "$out\x00" | dd of=$out/lib/vst3/"Amp Locker.vst3"/Contents/x86_64-linux/"Amp Locker.so" conv=notrunc bs=1 seek=$((${new_path_address_vst3})) count=${new_path_length}
    chmod +x $out/lib/vst3/"Amp Locker.vst3"/Contents/x86_64-linux/"Amp Locker.so"

    patchelf --set-interpreter $(cat ${stdenv.cc}/nix-support/dynamic-linker) $out/bin/"Amp Locker Standalone"
    patchelf --add-rpath ${libraryPath} $out/bin/"Amp Locker Standalone"
    patchelf --add-rpath ${libraryPath} $out/lib/vst3/"Amp Locker.vst3"/Contents/x86_64-linux/"Amp Locker.so"
  '';

  meta = with lib; {
    description = "AudioAssault Amp Locker";
    homepage = "https://audioassault.mx/";
    platforms = platforms.all;
    maintainers = with maintainers; [ polygon ];
  };
}
