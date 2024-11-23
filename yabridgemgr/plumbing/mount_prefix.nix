{ writeShellScriptBin, fuse-overlayfs, wineprefix, squashfuse, mktemp, coreutils
}:
writeShellScriptBin "mount_prefix" ''
  echo "Creating tmpfir" >&2
  TMPDIR="$HOME/yabridgemgr"
  ${coreutils}/bin/mkdir -p $TMPDIR/squash
  ${coreutils}/bin/mkdir -p $TMPDIR/upper
  ${coreutils}/bin/mkdir -p $TMPDIR/work

  echo "Mounting squashfs" >&2
  ${squashfuse}/bin/squashfuse ${wineprefix}/wineprefix.squashfs $TMPDIR/squash
  ${coreutils}/bin/ls -la $TMPDIR/squash

  echo "Mounting fusefs" >&2
  ${fuse-overlayfs}/bin/fuse-overlayfs -o lowerdir=$TMPDIR/squash -o upperdir=$TMPDIR/upper -o workdir=$TMPDIR/work -o squash_to_uid=$(${coreutils}/bin/id -u) -o squash_to_gid=$(${coreutils}/bin/id -g) $TMPDIR
''
