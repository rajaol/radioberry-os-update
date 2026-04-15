 1  sudo raspi-config
    2  ssh localhost
    3  uname -a
    4  sudo apt update
    5  sudo apt upgrade
    6  ssh localhost
    7  ifconfig
    8  sudo reboot
    9  wget https://raw.githubusercontent.com/pa3gsb/Radioberry-2.x/master/SBC/rpi-4/releases/dev/radioberry_install.sh
   10  chmod +x radioberry_install.sh
   11  ./radioberry_install.sh
   12  sudo apt install build-essentials
   13  sudo apt install build-essential
   14  sudo apt install raspberrypi-kernel-headers
   15  ./radioberry_install.sh
   16  sudo nano /boot/firmware/config.txt
   17  sudo nano /boot/firmware/cmdline.txt
   18  cat  /boot/firmware/cmdline.txt
   19  cat /boot/firmware/config.txt
   20  sudo nano /boot/firmware/cmdline.txt
   21  sudo nano /boot/firmware/config.txt
   22  ls
   23  wget https://raw.githubusercontent.com/vu3rdd/radioberry-controller-pi-config/master/pihpsdr_install.sh
   24  chmod +x pihpsdr_install.sh
   25  ./radioberry_install.sh
   26  sudo apt install linux-headers-rpi-v8
   27  sudo apt install linux-image-rpi-v7l
   28  sudo apt install linux-headers-rpi-v7l
   29  sudo apt remove linux-image-rpi-v8 linux-headers-rpi-v8
   30  sudo update-initramfs -u
   31  sudo reboot
   32  sudo nano /boot/firmware/config.txt
   33  sudo apt install arandr
   34  sudo nano /boot/firmware/cmdline.txt
   35  sudo reboot;exit
   36  arandr
   37  DISPLAY=:0 arandr
   38  sudo apt purge arandr
   39  sudo apt install arandr
   40  arandr
   41  sudo apt install xrandr
   42  sudo raspi-config
   43  ls
   44  ./radioberry_install.sh
   45  ls
   46  sudo reboot
   47  cat > check_radioberry.sh
   48  chmod +x check_radioberry.sh
   49  ./check_radioberry.sh
   50  ls
   51  ./pihpsdr_install.sh
   52  mount
   53  cp /media/pi/rootfs/home/pi/00-01-02-03-04-05.props ./
   54  sudo reboot;exit
   55  ./pihpsdr_install.sh
   56  ls -la /lib/firmware/radioberry.rbf
   57  ls
   58  ./check_radioberry.sh
   59  cat > check.sh
   60  chmod +x check.sh
   61  ./check
   62  ./check.sh
   63  ls
   64  ls -l Radioberry-2.x/SBC/rpi-4/releases/dev/CL016/radioberry.rbf
   65  ls -las /media/pi/rootfs/lib/firmware/radioberry.rbf
   66  sudo cp /media/pi/rootfs/lib/firmware/radioberry.rbf  /lib/firmware/
   67  sudo reboot;exit
