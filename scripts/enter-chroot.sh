#!/bin/bash
# enter-chroot.sh - Mount virtual filesystems and enter the ArionFS (LFS) chroot

set -e

LFS="${LFS:-/mnt/lfs}"
UUID="c98195f7-36dc-4c48-b94b-b2a3d029d873"

if [ "$EUID" -ne 0 ]; then
  echo "Run this script as root or with sudo." >&2
  exit 1
fi

mkdir -p "$LFS"

if ! mountpoint -q "$LFS"; then
  echo "Mounting partition UUID=$UUID to $LFS..."
  mount UUID="$UUID" "$LFS"
fi

echo "Mounting virtual filesystems..."
mount -v --bind /dev "$LFS/dev"
mount -v --bind /dev/pts "$LFS/dev/pts"
mount -vt proc proc "$LFS/proc"
mount -vt sysfs sysfs "$LFS/sys"
mount -vt tmpfs tmpfs "$LFS/run"

if [ -h "$LFS/dev/shm" ]; then
  install -v -d -m 1777 "$LFS$(realpath /dev/shm)"
else
  mount -vt tmpfs -o nosuid,nodev tmpfs "$LFS/dev/shm"
fi

echo "Entering chroot ($LFS)..."
chroot "$LFS" /usr/bin/env -i \
    HOME=/root \
    TERM="$TERM" \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin \
    /bin/bash --login
