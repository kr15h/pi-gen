#!/bin/bash -e

echo "---"
echo "Update and upgrade"

on_chroot << EOF
apt-get update
apt-get -y upgrade
apt-get -y dist-upgrade
apt-get clean
EOF

echo "Done!"
echo "---"
