# Minimalistic linux


## About the linux

It is built with very minimal features. The kernel and busybox version can be customized. Final image built will be executed using qemu emulator. Once the linux is up, you can play around with bunch of busybox commands.

## Prerequisite

The below packages needs to be installed before building the linux

```shell
sudo apt install pahole cpio xmlto python-sphinx python-sphinx_rtd_theme perl txr xz libelf-dev

sudo apt install gcc clang make binutils flex bison pahole util-linux kmod e2fsprogs jfsutils reiserfsprogs xfsprogs squashfs-tools btrfs-progs pcmciautils quota-tools ppp nfs-utils procps udev grub mcelog iptables openssl libcrypto bc
```

## Build steps

By default, kernel and buxybox version will be

```
KERNEL_VERSION=5.9.4
BUSYBOX_VERSION=1.35.0
```

>To modify the version, choose the kernel and busybox version from these official website and modify it in mini_linux_support.sh
>
>kernel source code  : https://mirrors.edge.kernel.org/pub/linux/kernel/
>[ Note: Choose kernel version of package that ends with ".tar.xz" ]
>eg: For kernel, _linux-5.7.5.tar.xz_ -> **KERNEL_VERSION=5.7.5**
>
>busybox source code : https://busybox.net/downloads/ 
>[ Note: Choose busybox version of package that ends with ".tar.bz2" ]
>eg: For busybox, _busybox-1.34.1.tar.bz2_ -> **BUSYBOX_VERSION=1.34.1**

After configuring kernel and busybox version, do
>* make build - To build the linux and create run script.
>* make boot  - To start the linux that was built.
>* make all   - To build and boot the linux in one go.
>* make clean - To remove all builds and downloads.
