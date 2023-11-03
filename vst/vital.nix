# Patch Vital VST3 with libc.so.6 from unstable
{
  vital
, stdenv
, patchelf
, lib
, glibc
}:
stdenv.mkDerivation {
  pname = "vital";
  version = "1.5.5";

  unpackPhase = ''true'';
  dontConfigure = true;
  dontBuild = true;
  dontPatch = true;

  installPhase = ''
    mkdir -p $out
    mkdir -p $out/lib
    cp -a ${vital}/bin $out
    cp -a ${vital}/lib/vst3 $out/lib
  '';

  preFixup = ''
    patchelf --add-rpath ${lib.makeLibraryPath [ glibc ]} $out/lib/vst3/Vital.vst3/Contents/x86_64-linux/Vital.so
  '';
}
