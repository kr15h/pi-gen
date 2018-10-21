#!/bin/bash -e

OFX_URL="https://openframeworks.cc/versions/v0.10.0/of_v0.10.0_linuxarmv6l_release.tar.gz"
OFX_DST="ofx.tar.gz"
OFX_DIR="ofx"

if [ -f ${OFX_DST} ]; then
	rm ${OFX_DST}
fi

if [ -d ${OFX_DIR} ]; then
	rm -rf ${OFX_DIR}
fi

wget --no-check-certificate ${OFX_URL} -O ${OFX_DST}
mkdir ${OFX_DIR}
tar vxfz ${OFX_DST} -C ${OFX_DIR} --strip-components 1

echo "ofx download successful"

# Move openFrameworks directory to Raspberry Pi filesystem.
# We use cp instead of install here because install has yet
# unknown directory copy behaviour.
cp -r ${OFX_DIR} ${ROOTFS_DIR}/home/pi/

# Enter chroot on Raspberry Pi (act as if you were root on Pi)
on_chroot << EOF

# Fix ownership and permissions as a result using cp.
chown -R pi:pi /home/pi/${OFX_DIR}
chmod -R 755 /home/pi/${OFX_DIR}

# Enter the openFrameworks scripts directory and run the
# instal_dependencies.sh script as user pi.
cd /home/pi/${OFX_DIR}/scripts/linux/debian
sed -i "s/apt-get/apt-get -y/g" ./install_dependencies.sh
./install_dependencies.sh
echo "install dependencies: OK"

# Compile openFrameworks as user pi
su pi
make Release -C /home/pi/${OFX_DIR}/examples/3d/3DPrimitivesExample

# Run app on boot
crontab -l > /home/pi/cronex
echo "@reboot /home/pi/${OFX_DIR}/examples/3d/3DPrimitivesExample/bin/3DPrimitivesExample" >> /home/pi/cronex
crontab /home/pi/cronex
rm /home/pi/cronex
EOF

rm ${OFX_DST}
rm -rf ${OFX_DIR}

echo "ofx install successful"

