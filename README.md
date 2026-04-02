Radioberry SDR - Complete Installation Guide for Raspberry Pi OS 32-bit
This guide provides step-by-step instructions for installing Radioberry SDR on Raspberry Pi OS 32-bit, including troubleshooting of common kernel header and driver issues.

Prerequisites
Raspberry Pi (tested on Pi 4 Model B)

Radioberry SDR board

MicroSD card (16GB minimum)

Internet connection

Step 1: Install Raspberry Pi OS 32-bit
Download and install Raspberry Pi OS (Legacy, 32-bit) from the official website.

After installation, boot your Pi and update the system:

bash
sudo apt update && sudo apt upgrade -y
Step 2: Verify System Architecture
bash
uname -a
# Should show: armv7l (32-bit)
# If it shows aarch64, you need to force 32-bit mode (see Step 3)
Step 3: Force 32-bit Kernel (If needed)
If your system shows 64-bit kernel (aarch64), add these lines to /boot/firmware/config.txt:

bash
sudo nano /boot/firmware/config.txt
Add these lines:

ini
# Force 32-bit mode for Radioberry
arm_64bit=0
kernel=kernel7l.img
Save and reboot:

bash
sudo reboot
Verify after reboot:

bash
uname -m
# Should show: armv7l
Step 4: Install Required Dependencies
bash
# Install build tools and kernel headers
sudo apt update
sudo apt install -y build-essential dkms git device-tree-compiler

# Install kernel headers
sudo apt install -y raspberrypi-kernel-headers

# Verify headers installation
ls /usr/src/linux-headers-$(uname -r)
Step 5: Download Radioberry Source Code
bash
cd /tmp
git clone https://github.com/pa3gsb/Radioberry-2.x.git
cd Radioberry-2.x
Step 6: Build and Install the Driver
bash
# Clean previous builds (if any)
make clean

# Install for Cyclone 10 CL016 (or your FPGA type)
sudo make install FPGATYPE=CL016
Step 7: Install the Device Tree Overlay
bash
# Copy the overlay
sudo cp /tmp/Radioberry-2.x/SBC/rpi-4/device_driver/driver/radioberry.dtbo /boot/firmware/overlays/

# Configure config.txt
sudo bash -c 'cat >> /boot/firmware/config.txt << EOF

# Radioberry settings
dtparam=spi=on
dtoverlay=radioberry
EOF'

# Reboot
sudo reboot
Step 8: Verify Driver Installation
After reboot, check the following:

bash
# Check kernel module
lsmod | grep radioberry

# Check device node
ls -la /dev/radioberry

# Check kernel messages
dmesg | grep -i radioberry

# Check device tree overlay
ls /proc/device-tree/ | grep -i radio
Expected output should show:

radioberry module loaded

/dev/radioberry device node exists

Kernel messages showing successful initialization

Step 9: Install Radioberry Daemon
bash
# Copy daemon binary (if not already installed)
sudo cp /tmp/Radioberry-2.x/SBC/rpi-4/device_driver/firmware/radioberry /usr/local/bin/
sudo chmod +x /usr/local/bin/radioberry

# Fix service permissions
sudo chmod -x /etc/systemd/system/radioberry.service
sudo systemctl daemon-reload
Step 10: Start the Radioberry Service
bash
# Enable and start the service
sudo systemctl enable radioberry
sudo systemctl start radioberry

# Check status
sudo systemctl status radioberry
Step 11: Install pihpsdr (GUI Application)
The pihpsdr application should have been installed during the make install step. Verify:

bash
# Check if pihpsdr is installed
which pihpsdr

# Run pihpsdr
pihpsdr
Troubleshooting Common Issues
Issue 1: Kernel headers not found
Error: make: *** /lib/modules/$(uname -r)/build: No such file or directory

Solution:

bash
# Reinstall kernel headers
sudo apt install --reinstall raspberrypi-kernel-headers

# Create symlink manually if needed
sudo ln -sf /usr/src/linux-headers-$(uname -r) /lib/modules/$(uname -r)/build
Issue 2: Module not found after installation
Error: modprobe: FATAL: Module radioberry not found

Solution:

bash
# Manually copy module to correct location
sudo cp /tmp/Radioberry-2.x/SBC/rpi-4/device_driver/driver/radioberry.ko /lib/modules/$(uname -r)/extra/
sudo depmod -a
sudo modprobe radioberry
Issue 3: Exec format error
Error: modprobe: ERROR: could not insert 'radioberry': Exec format error

Solution: This indicates architecture mismatch. Ensure you're running 32-bit kernel:

bash
# Check architecture
uname -m
# Should show armv7l, not aarch64

# If showing aarch64, add to /boot/firmware/config.txt:
arm_64bit=0
kernel=kernel7l.img
Issue 4: Device node not created
Error: /dev/radioberry doesn't exist even though module is loaded

Solution:

bash
# Check if overlay is loaded
ls /proc/device-tree/ | grep -i radio

# If not, reload overlay
sudo dtoverlay radioberry

# Or reboot after adding to config.txt
sudo reboot
Issue 5: Service keeps restarting
Error: Service shows "activating (auto-restart)"

Solution:

bash
# Check service logs
sudo journalctl -u radioberry -n 50 --no-pager

# Ensure daemon binary exists
ls -la /usr/local/bin/radioberry

# Reinstall daemon if missing
sudo cp /tmp/Radioberry-2.x/SBC/rpi-4/device_driver/firmware/radioberry /usr/local/bin/
sudo chmod +x /usr/local/bin/radioberry
Issue 6: Missing gcc-12 dependency
Error: Depends: gcc-12:arm64 but it is not installable

Solution: This occurs on 64-bit systems. Switch to 32-bit OS or use the armhf version:

bash
# Install 32-bit compiler
sudo apt install gcc-12:armhf
Complete Verification Checklist
Run this script to verify everything is working:

bash
#!/bin/bash
echo "=== Radioberry Installation Verification ==="
echo ""

echo "1. Kernel Architecture:"
uname -m
echo ""

echo "2. Kernel Version:"
uname -r
echo ""

echo "3. Radioberry Module:"
lsmod | grep radioberry || echo "NOT LOADED"
echo ""

echo "4. Device Node:"
ls -la /dev/radioberry 2>/dev/null || echo "NOT FOUND"
echo ""

echo "5. Device Tree Overlay:"
ls /proc/device-tree/ | grep -i radio || echo "NOT LOADED"
echo ""

echo "6. Service Status:"
sudo systemctl is-active radioberry
echo ""

echo "7. Recent Kernel Messages:"
dmesg | grep -i radioberry | tail -5
echo ""

echo "8. Daemon Binary:"
ls -la /usr/local/bin/radioberry 2>/dev/null || echo "NOT FOUND"
echo ""

echo "9. Gateware File:"
ls -la /lib/firmware/radioberry.rbf 2>/dev/null || echo "NOT FOUND"
echo ""

echo "10. pihpsdr Binary:"
which pihpsdr 2>/dev/null || echo "NOT FOUND"
Uninstallation
If you need to remove Radioberry:

bash
# Stop and disable service
sudo systemctl stop radioberry
sudo systemctl disable radioberry

# Remove module
sudo modprobe -r radioberry

# Remove files
sudo rm -f /lib/modules/$(uname -r)/extra/radioberry.ko
sudo rm -f /usr/local/bin/radioberry
sudo rm -f /usr/local/bin/pihpsdr
sudo rm -f /usr/local/lib/libwdsp.so
sudo rm -f /lib/firmware/radioberry.rbf
sudo rm -f /etc/systemd/system/radioberry.service
sudo rm -f /etc/init.d/radioberryd
sudo rm -f /boot/firmware/overlays/radioberry.dtbo

# Remove config lines (manual edit required)
sudo nano /boot/firmware/config.txt
# Remove lines: dtparam=spi=on and dtoverlay=radioberry

# Update module dependencies
sudo depmod -a

# Reboot
sudo reboot
References
Radioberry GitHub Repository

Raspberry Pi Documentation

Support
For issues specific to Radioberry, please open an issue on the Radioberry GitHub repository.

Note: This g
