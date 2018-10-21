#!/bin/bash -e

OFX_URL="https://openframeworks.cc/versions/v0.10.0/of_v0.10.0_linuxarmv6l_release.tar.gz"
OFX_DST="ofx.tar.gz"
OFX_DIR="ofx"
OFX_RFS="/home/pi"

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

install -m 755 -d ${OFX_DIR} ${ROOTFS_DIR}/${OFX_RFS}/
on_chroot << EOF
chown -R pi:pi ${OFX_RFS}
EOF

rm ${OFX_DST}
rm -rf ${OFX_DIR}

echo "ofx install successful"

