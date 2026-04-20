# Canon LBP 2900 Installer for Modern Ubuntu (24.04+)

This repository provides an automated wrapper script to install the Canon LBP 2900 printer on modern Ubuntu distributions. 

Recent Ubuntu releases have deprecated several 32-bit libraries and transitioned to a new ABI for `libxml2`, breaking existing installation methods and Canon's proprietary CAPT drivers. This script fully automates the necessary workarounds.

## What This Script Does
1. Enables the `i386` architecture.
2. Builds a lightweight "dummy" package to safely bypass obsolete GUI dependencies (`libglade2-0`).
3. Fetches and installs legacy `libicu74` and `libxml2` binaries from the Ubuntu 24.04 archives.
4. Clones and patches the community driver script by [archisman-panigrahi](https://github.com/archisman-panigrahi/ubuntu_canon_printer) to remove hardcoded, broken dependencies.
5. Replaces the broken `init.d` startup process with a modern `systemd` service file to ensure the `ccpd` daemon runs persistently.

## Installation

Run the following commands in your terminal:

\`\`\`bash
git clone https://github.com/YOUR_USERNAME/ubuntu-canon-lbp2900.git
cd ubuntu-canon-lbp2900
chmod +x install_lbp2900.sh
sudo ./install_lbp2900.sh
\`\`\`

During the installation, the script will pause and ask you for input. 
* Press **1** to install.
* Enter the number corresponding to the **LBP2900**.
* Press **1** to select the USB connection.
* Turn your printer off and back on when prompted.

## Troubleshooting
If the printer stops working after a reboot, you can restart the daemon manually:
\`\`\`bash
sudo systemctl restart ccpd.service
\`\`\`
