{ writeShellScriptBin, util-linux }:
writeShellScriptBin "umount_prefix" ''
  echo "Unmounting overlayfs" >&2
  TMPDIR="$HOME/yabridgemgr"

  ${util-linux}/bin/umount $TMPDIR

  echo "Unmounting squashfs" >&2
  ${util-linux}/bin/umount $TMPDIR/squash
''
