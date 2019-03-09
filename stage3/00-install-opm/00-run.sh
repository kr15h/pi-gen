#!/bin/bash -e

OFX_DIR="ofx"

if [ -d ${OFX_DIR} ]; then
	rm -rf ${OFX_DIR}
fi

if [ -d ${ROOTFS_DIR}/home/pi/${OFX_DIR} ]; then
	rm -rf ${ROOTFS_DIR}/home/pi/${OFX_DIR}
fi

if [ -d ${ROOTFS_DIR}/home/pi/addons/ofxJSON ]; then
	rm -rf ${ROOTFS_DIR}/home/pi/addons/ofxJSON
fi

if [ -d ${ROOTFS_DIR}/home/pi/addons/ofxOMXPlayer ]; then
	rm -rf ${ROOTFS_DIR}/home/pi/addons/ofxOMXPlayer
fi

if [ -d ${ROOTFS_DIR}/home/pi/addons/ofxPiMapper ]; then
	rm -rf ${ROOTFS_DIR}/home/pi/addons/ofxPiMapper
fi

git clone --depth=1  https://github.com/openframeworks/openFrameworks.git \
	"${ROOTFS_DIR}/home/pi/${OFX_DIR}"
git clone --depth=1 https://github.com/jeffcrouse/ofxJSON.git \
	"${ROOTFS_DIR}/home/pi/${OFX_DIR}/addons/ofxJSON"
git clone --depth=1 https://github.com/jvcleave/ofxOMXPlayer.git \
	"${ROOTFS_DIR}/home/pi/${OFX_DIR}/addons/ofxOMXPlayer"
git clone --depth=1 https://github.com/kr15h/ofxPiMapper.git \
	"${ROOTFS_DIR}/home/pi/${OFX_DIR}/addons/ofxPiMapper"

# Enter chroot on Raspberry Pi (act as if you were root on Pi)
on_chroot << EOF

# Install USB packages and other fun things
apt-get -y install usbmount dosfstools exfat-fuse exfat-utils
apt-get -y install tree htop

# Make Raspbian Stretch to mount our USB drives
sed -i -r "s/MountFlags=slave/MountFlags=shared/" /lib/systemd/system/systemd-udevd.service

# Change memory split, give more to the GPU
echo "gpu_mem_256=128" >> /boot/config.txt
echo "gpu_mem_512=256" >> /boot/config.txt
echo "gpu_mem_1024=512" >> /boot/config.txt
sed -i -r "s/gpu_mem=[0-9]+//" /boot/config.txt

# Fix ownership and permissions as a result using cp and git clone
chown -R pi:pi /home/pi/${OFX_DIR}
chmod -R 755 /home/pi/${OFX_DIR}

# Install openFrameworks dependencies as root
cd /home/pi/${OFX_DIR}/scripts/linux/debian
sed -i "s/apt-get/apt-get -y/g" ./install_dependencies.sh
./install_dependencies.sh

# Download libs
cd /home/pi/${OFX_DIR}/scripts/linux
./download_libs.sh

# Install addon dependencies
cd /home/pi/${OFX_DIR}/addons/ofxOMXPlayer
./install_depends.sh

# Compile as user pi
su pi
make Release -C /home/pi/${OFX_DIR}/addons/ofxPiMapper/example_basic

# Create startup script
cp /home/pi/${OFX_DIR}/addons/ofxPiMapper/scripts/startup.sh /home/pi/
chmod a+x /home/pi/startup.sh

# Run app on boot
crontab -l > /home/pi/cronex
echo "@reboot /home/pi/startup.sh" >> /home/pi/cronex
crontab /home/pi/cronex
rm /home/pi/cronex
EOF

rm -rf ${OFX_DIR}

echo "ofx install successful"

