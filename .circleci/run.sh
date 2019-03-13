#!/bin/bash

whoami
uname -a
ls -l
apt-get update
apt-get -y install coreutils quilt parted qemu-user-static debootstrap zerofree pxz zip dosfstools bsdtar libcap2-bin grep rsync xz-utils file git curl xxd kmod
touch config
echo 'IMG_NAME=opm' >> config
if [ -f ../stage0/EXPORT_NOOBS ]; then rm ../stage0/EXPORT_NOOBS; fi
if [ -f ../stage1/EXPORT_NOOBS ]; then rm ../stage1/EXPORT_NOOBS; fi
if [ -f ../stage2/EXPORT_NOOBS ]; then rm ../stage2/EXPORT_NOOBS; fi
if [ -f ../stage0/EXPORT_IMAGE ]; then rm ../stage0/EXPORT_IMAGE; fi
if [ -f ../stage1/EXPORT_IMAGE ]; then rm ../stage1/EXPORT_IMAGE; fi
if [ -f ../stage2/EXPORT_IMAGE ]; then rm ../stage2/EXPORT_IMAGE; fi
touch ../stage4/SKIP ../stage5/SKIP
touch ../stage4/SKIP_IMAGES ../stage5/SKIP_IMAGES
touch ../stage3/EXPORT_IMAGE
./build.sh
