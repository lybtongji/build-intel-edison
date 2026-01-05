#!/bin/sh

[ -z "${DEPLOY}" ] && exit 1
[ -z "${ROOTFS}" ] && exit 1
[ -z "${IMAGE_EXT4}" ] && exit 1

apt update
apt install -y debootstrap

rm -rf ${ROOTFS}
mkdir -p ${ROOTFS}

function join_by { local IFS="$1"; shift; echo "$*"; }

pkgs=(
    bash-completion
    curl
    dbus
    dbus-user-session
    openssh-server
    # policykit-1
    polkitd
    sudo
    systemd-resolved
    systemd-timesyncd
    vim
    wpasupplicant
)

debootstrap \
    --arch amd64 \
    --merged-usr \
    --no-check-gpg \
    --include $(join_by , ${pkgs[*]}) \
    stable ${ROOTFS} https://deb.debian.org/debian

install -d ${ROOTFS}/boot
install -m 0755 ${DEPLOY}/images/edison/bzImage ${ROOTFS}/boot/bzImage
install -m 0755 ${DEPLOY}/images/edison/core-image-minimal-initramfs-edison.cpio.gz ${ROOTFS}/boot/initrd

cp -r ${DEPLOY}/deb ${ROOTFS}/tmp/
rm -v ${ROOTFS}/tmp/deb/edison/kernel-{dev,dbg}_*.deb

mount -t proc /proc ${ROOTFS}/proc
mount -t sysfs /sys ${ROOTFS}/sys
mount -o bind /dev ${ROOTFS}/dev
mount -o bind /dev/pts ${ROOTFS}/dev/pts

chroot ${ROOTFS} bash -c "dpkg -i --force-bad-version /tmp/deb/edison/kernel-*.deb"
chroot ${ROOTFS} bash -c "dpkg -i /tmp/deb/all/bcm43340-fw_*.deb"
chroot ${ROOTFS} bash -c "dpkg -i /tmp/deb/corei7-64/gadget_*.deb"

umount ${ROOTFS}/dev/pts
umount ${ROOTFS}/dev
umount ${ROOTFS}/sys
umount ${ROOTFS}/proc

rm -rf ${ROOTFS}/tmp/*

echo edison > ${ROOTFS}/etc/hostname
ln -s /lib/systemd/system/serial-getty@.service ${ROOTFS}/etc/systemd/system/multi-user.target.wants/serial-getty@ttyS2.service
sed -i 's/^root:[^:]*/root:/' ${ROOTFS}/etc/shadow

echo ROOTFS size $(du -sb ${ROOTFS} | cut -f1)
mkfs.ext4 -d ${ROOTFS} ${IMAGE_EXT4} 1048576
