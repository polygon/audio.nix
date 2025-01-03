{ stdenv, bindfs, bubblewrap, mktemp, writeShellScript, bitwig-studio }:
stdenv.mkDerivation {
  inherit (bitwig-studio) pname version;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  dontPatchELF = true;
  dontStrip = true;

  installPhase = let
    wrapper = writeShellScript "bitwig-studio" ''
      echo "Creating temporary directory"
      TMPDIR=$(${mktemp}/bin/mktemp --directory)
      echo "Temporary directory: $TMPDIR"
      echo "Copying default Vamp Plugin settings"
      cp -r ${bitwig-studio}/libexec/resources/VampTransforms $TMPDIR
      echo "Changing permissions to be writable"
      chmod -R u+w $TMPDIR/VampTransforms

      echo "Starting Bitwig Studio in Bubblewrap Environment"
      ${bubblewrap}/bin/bwrap --dev-bind / / --bind $TMPDIR/VampTransforms ${bitwig-studio}/libexec/resources/VampTransforms ${bitwig-studio}/bin/bitwig-studio

      echo "Bitwig exited, removing temporary directory"
      rm -rf $TMPDIR
    '';
  in ''
    mkdir -p $out/bin
    cp ${wrapper} $out/bin/bitwig-studio
    cp -r ${bitwig-studio}/share $out
  '';
}
