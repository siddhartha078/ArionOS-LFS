# ArionOS: Linux From Scratch 12.4

ArionOS is a custom Linux From Scratch system built following the LFS 12.4 (SysVinit) specification. This repository contains the configurations, patches, and package manifests needed to reproduce and maintain the installation.

## System profile

- Distribution ID: ArionOS
- Release: 12.4
- Kernel version: 6.16.1
- Init system: SysVinit 3.14
- Root partition: `/dev/nvme0n1p7`
- Root filesystem UUID: `c98195f7-36dc-4c48-b94b-b2a3d029d873`
- Host network interfaces: `eno1` (Realtek r8169) and `wlan0` (Realtek rtw89_8852be)
- Console keymap: US, LatArCyrHeb-16 font

## Directory layout

```text
lfs/
├── README.md               # System specification and documentation
├── .gitignore              # Git ignore rules for build artifacts
├── configs/
│   ├── kernel.config       # Linux kernel 6.16.1 .config
│   ├── fstab               # File system table with partition UUIDs
│   ├── inittab             # Runlevel and console spawn definitions
│   ├── hostname            # System hostname (arionfs)
│   ├── hosts               # Local hostname mapping
│   ├── profile             # Default locale and shell environment
│   ├── shells              # Valid login shells
│   ├── inputrc             # Readline navigation bindings
│   ├── ld.so.conf          # Dynamic linker search paths
│   ├── os-release          # Distribution identification
│   ├── sysconfig/          # Network, clock, console, and rc.site settings
│   └── udev/               # Persistent network and clock rules
├── manifests/
│   ├── wget-list           # Full package download URL list
│   ├── wget-list-sysv      # SysV specific package list
│   └── md5sums             # Source verification checksums
├── patches/                # Upstream and FHS fixes for core packages
│   ├── bzip2-1.0.8-install_docs-1.patch
│   ├── coreutils-9.7-i18n-1.patch
│   ├── coreutils-9.7-upstream_fix-1.patch
│   ├── expect-5.45.4-gcc15-1.patch
│   ├── glibc-2.42-fhs-1.patch
│   ├── kbd-2.8.0-backspace-1.patch
│   └── sysvinit-3.14-consolidated-1.patch
└── scripts/
    └── enter-chroot.sh     # Mounts virtual filesystems and enters chroot
```

## Maintenance and rebuild guide

### Downloading sources
To fetch the sources defined in the manifest:

```bash
mkdir -p sources
cd sources
wget --input-file=../manifests/wget-list --continue --directory-prefix=.
pushd .
md5sum -c ../manifests/md5sums
popd
```

### Entering the environment
Use the included helper script to bind virtual filesystems and drop into the chroot:

```bash
sudo ./scripts/enter-chroot.sh
```

To clean up mounts manually after leaving the chroot:

```bash
sudo umount -v $LFS/dev/pts
sudo umount -v $LFS/dev/shm
sudo umount -v $LFS/dev
sudo umount -v $LFS/run
sudo umount -v $LFS/proc
sudo umount -v $LFS/sys
sudo umount -v $LFS
```

### Kernel configuration
The kernel configuration is stored at `configs/kernel.config`. To compile or update the kernel:

```bash
cd /usr/src/linux-6.16.1
cp /path/to/configs/kernel.config .config
make olddefconfig
make -j$(nproc)
make modules_install
cp -iv arch/x86/boot/bzImage /boot/vmlinuz-6.16.1-lfs-12.4
cp -iv System.map /boot/System.map-6.16.1
cp -iv .config /boot/config-6.16.1
```

### GRUB configuration entry
Add the following stanza to the host or bootloader GRUB menu (`/boot/grub/grub.cfg` or `/etc/grub.d/40_custom`):

```text
menuentry 'ArionFS 12.4 (Linux 6.16.1)' {
    insmod ext2
    search --no-floppy --fs-uuid --set=root c98195f7-36dc-4c48-b94b-b2a3d029d873
    linux /boot/vmlinuz-6.16.1-lfs-12.4 root=UUID=c98195f7-36dc-4c48-b94b-b2a3d029d873 ro quiet
}
```
