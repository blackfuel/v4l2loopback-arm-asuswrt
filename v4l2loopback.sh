#!/bin/bash
#############################################################################
# v4l2loopbackup for AsusWRT
#
# This script is a kernel patch for adding v4l2loopbackup capability to 
# Asus ARM routers.
#
# Location of the new kernel modules after building the AsusWRT firmware:
# ~/asuswrt-merlin/release/src/router/arm-uclibc/target/lib/modules/2.6.36.4brcmarm/kernel/drivers/media
#
#############################################################################
PATH_CMD="$(readlink -f $0)"

set -e
set -x

# directories
MERLINDIR="$HOME/asuswrt-merlin"
PACKAGEDIR="$HOME/v4l2loopback"

# download v4l2loopback
cd
git clone https://github.com/umlaeute/v4l2loopback.git

# apply patch to add v4l2loopback kernel option
pushd .
cd $MERLINDIR
PATCH_NAME="${PATH_CMD%/*}/asuswrt-arm-v4l2loopback.patch"
patch --dry-run --silent -p2 -i "$PATCH_NAME" >/dev/null 2>&1 && \
  patch -p2 -i "$PATCH_NAME" || \
  echo "The Linux kernel patch was not applied."
popd

# create symbolic links in Asuswrt-Merlin to the source files in v4l2loopback project
for KERNELDIR in "src-rt-6.x.4708" "src-rt-7.14.114.x/src" "src-rt-7.x.main/src"; do
  [ ! -h $MERLINDIR/release/$KERNELDIR/linux/linux-2.6.36/drivers/media/video/v4l2loopback.c ] && ln -sf $PACKAGEDIR/v4l2loopback.c $MERLINDIR/release/$KERNELDIR/linux/linux-2.6.36/drivers/media/video/v4l2loopback.c
  [ ! -h $MERLINDIR/release/$KERNELDIR/linux/linux-2.6.36/drivers/media/video/v4l2loopback_formats.h ] && ln -sf $PACKAGEDIR/v4l2loopback_formats.h $MERLINDIR/release/$KERNELDIR/linux/linux-2.6.36/drivers/media/video/v4l2loopback_formats.h
done

