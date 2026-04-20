#!/bin/bash

# Ensure the script is run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root (e.g., sudo ./install_lbp2900.sh)"
  exit 1
fi

echo "=== Canon LBP 2900 Modern Ubuntu Installer ==="
echo "This script resolves legacy dependencies, patches the community driver, and configures systemd."

# 1. Architecture and Base Dependencies
echo -e "\n[1/6] Enabling 32-bit architecture and installing base tools..."
dpkg --add-architecture i386
apt-get update
apt-get install -y git wget equivs libpango-1.0-0:i386

# 2. Dummy Package for Obsolete GUI Dependencies
echo -e "\n[2/6] Building dummy package to bypass obsolete GUI dependencies..."
cat <<EOF > libglade2-0-dummy
Section: misc
Priority: optional
Standards-Version: 3.9.2
Package: libglade2-0
Version: 1:2.5.1
Description: Dummy package to satisfy Canon CAPT dependencies
EOF
equivs-build libglade2-0-dummy
dpkg -i libglade2-0_*.deb

# 3. Legacy XML Dependencies for Modern Ubuntu (24.04+)
echo -e "\n[3/6] Fetching and installing legacy libxml2 packages..."
wget -qnc http://archive.ubuntu.com/ubuntu/pool/main/i/icu/libicu74_74.2-1ubuntu3_amd64.deb
wget -qnc http://archive.ubuntu.com/ubuntu/pool/main/libx/libxml2/libxml2_2.9.14+dfsg-1.3ubuntu3.7_amd64.deb
dpkg -i libicu74_74.2-1ubuntu3_amd64.deb
dpkg -i libxml2_2.9.14+dfsg-1.3ubuntu3.7_amd64.deb

# 4. Clone and Patch the Community Script
echo -e "\n[4/6] Cloning and patching the base installation script..."
if [ ! -d "ubuntu_canon_printer" ]; then
    git clone https://github.com/archisman-panigrahi/ubuntu_canon_printer.git
fi
cd ubuntu_canon_printer || exit

# Strip broken and renamed dependencies from the original script
sed -i 's/libglade2-0//g' canon_lbp_setup.sh
sed -i 's/libcanberra-gtk-module//g' canon_lbp_setup.sh
sed -i 's/libpango1.0-0:i386//g' canon_lbp_setup.sh
sed -i 's/libxml2:i386//g' canon_lbp_setup.sh

# 5. Execute the Installer
echo -e "\n[5/6] Running the installer."
echo "----------------------------------------------------"
echo "PLEASE FOLLOW THE ON-SCREEN PROMPTS:"
echo "  1. Press '1' to install"
echo "  2. Enter the number for 'LBP2900'"
echo "  3. Press '1' for USB connection"
echo "----------------------------------------------------"
chmod +x canon_lbp_setup.sh
./canon_lbp_setup.sh

# 6. Apply systemd Fix
echo -e "\n[6/6] Applying modern systemd fix for the CAPT daemon..."
cat <<EOF > /etc/systemd/system/ccpd.service
[Unit]
Description=Canon CAPT Printer Daemon
After=cups.service

[Service]
Type=forking
ExecStart=/usr/sbin/ccpd
TimeoutSec=15

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now ccpd.service
systemctl restart cups

echo -e "\n=== Installation Complete! ==="
echo "Your Canon LBP 2900 is now configured and ready to print."
