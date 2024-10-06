{ writeShellScriptBin, fuse-overlayfs, wineprefix, squashfuse, mktemp, coreutils
}:
writeShellScriptBin "mount_prefix" ''
  if [[ $# -ne 1 ]]; then
    echo "Usage: mount_prefix <destination-folder>" >&2
    exit 1
  fi

  echo "Creating tmpfir" >&2
  # TMPDIR=$(${mktemp}/bin/mktemp --directory)
  TMPDIR=$RUNTIME_DIRECTORY
  echo "$TMPDIR" >&2
  ${coreutils}/bin/mkdir $TMPDIR/squash
  ${coreutils}/bin/mkdir $TMPDIR/upper
  ${coreutils}/bin/mkdir $TMPDIR/work

  ${coreutils}/bin/ls -la /$TMPDIR >&2

  echo "Mounting squashfs" >&2
  ${squashfuse}/bin/squashfuse ${wineprefix}/wineprefix.squashfs $TMPDIR/squash
  ${coreutils}/bin/ls -la $TMPDIR/squash

  echo "Mounting fusefs" >&2
  echo "${fuse-overlayfs}/bin/fuse-overlayfs -o lowerdir=$TMPDIR/squash -o upperdir=$TMPDIR/upper -o workdir=$TMPDIR/work -o squash_to_uid=$(${coreutils}/bin/id -u) -o squash_to_gid=$(${coreutils}/bin/id -g) $1" >&2
  ${fuse-overlayfs}/bin/fuse-overlayfs -o lowerdir=$TMPDIR/squash -o upperdir=$TMPDIR/upper -o workdir=$TMPDIR/work -o squash_to_uid=$(${coreutils}/bin/id -u) -o squash_to_gid=$(${coreutils}/bin/id -g) $1
  ${coreutils}/bin/ls -la $1 >&2
''
