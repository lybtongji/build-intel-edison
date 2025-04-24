DESCRIPTION = "Custom image to make another EDISON disto"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"
LICENSE = "MIT"
IMAGE_INSTALL = "packagegroup-core-boot  ${CORE_IMAGE_EXTRA_INSTALL}"

IMAGE_LINGUAS = " "

# We don't want to include initrd - we have initramfs instead
#INITRD_LIVE = ""
DEPENDS += " core-image-minimal-initramfs"

# Do not use legacy nor EFI BIOS
PCBIOS = "0"
# Do not support bootable USB stick
NOISO = "1"
# Generate a HDD image
NOHDD = "0"
ROOTFS = ""

# Specify rootfs image type
IMAGE_FSTYPES += "ext4 live"

inherit core-image

IMAGE_ROOTFS_SIZE = "1048576"

IMAGE_INSTALL:append = " kernel-modules"

# Wifi firmware
# removed modules, already built into kernel
IMAGE_INSTALL:append = " bcm43340-fw"
IMAGE_INSTALL:append = " bcm43340-addr"

# Gadget setup
IMAGE_INSTALL:append = " gadget"
