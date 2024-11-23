{ writeShellScriptBin, util-linux }:
writeShellScriptBin "umount_prefix" ''
  echo "Unmounting overlayfs" >&2
  TMPDIR="$HOME/yabridgemgr"

  /run/wrappers/bin/umount $TMPDIR

  echo "Unmounting squashfs" >&2
  ${util-linux}/bin/umount $TMPDIR/squash
''
