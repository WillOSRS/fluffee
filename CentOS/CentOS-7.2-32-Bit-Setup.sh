#!/bin/bash

name=$1
sshport=$2
vncport=$3
sshpassword=$4
vncpassword=$5
echo -n "Installing updates..."
yum -y update &> /dev/null
echo " Done"
echo -n "Installing required packages and VNC..."
yum -y install epel-release sudo nano tigervnc-server gnome-system-monitor firefox &> /dev/null
echo " Done"
echo -n "Creating the user..."
chkconfig vncserver on &> /dev/null
adduser $name &> /dev/null
echo "$name:$sshpassword" | chpasswd
usermod -aG wheel $name &> /dev/null
sed -i "s/# %wheel/%wheel/g" /etc/sudoers
echo " Done"
echo -n "Setting up SSH..."
sed -i "s/#Port 22/Port $sshport/g" /etc/ssh/sshd_config
sed -i "s/#PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
echo "" >> /etc/ssh/sshd_config
echo "AllowUsers $name root" >> /etc/ssh/sshd_config
service sshd restart &> /dev/null
echo " Done"
echo -n "Installing XFCE..."
yum -y groupinstall xfce &> /dev/null
echo " Done"
echo -n "Setting up VNC..."
mkdir /home/$name/.vnc &> /dev/null
echo $vncpassword >/home/$name/.vnc/file
vncpasswd -f </home/$name/.vnc/file >/home/$name/.vnc/passwd
chown $name /home/$name/.vnc &> /dev/null
chown $name /home/$name/.vnc/passwd &> /dev/null
chgrp $name /home/$name/.vnc &> /dev/null
chgrp $name /home/$name/.vnc/passwd &> /dev/null
chmod 600 /home/$name/.vnc/passwd &> /dev/null
su  - $name -c "vncserver" &> /dev/null
su  - $name -c "vncserver -kill :1" &> /dev/null
sudo cp /lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:1.service
sudo sed -i -e 's![<]USER[>]!'"$name"'!g' /etc/systemd/system/vncserver@:1.service
sed -i "s/ \-x \/usr\/bin\/firefox \-a \-f \/usr\/share\/doc\/HTML\/index\.html / \-x \/bin\/xfce4-session /g" /etc/X11/xinit/Xclients
sed -i "s/\/usr\/bin\/firefox \/usr\/share\/doc\/HTML\/index\.html \&/exec \/bin\/xfce4-session /g" /etc/X11/xinit/Xclients
sed -i "s/$vncPort = 5900/$vncPort = $vncport - 1/g" /usr/bin/vncserver
mkdir /home/$name/.config/xfce4 &> /dev/null
if [ -f /home/$name/.config/xfce4/helpers.rc ]; then
    echo "FileManager=nautilus" >> /home/$name/.config/xfce4/helpers.rc &> /dev/null
fi
systemctl start vncserver@:1.service &> /dev/null
systemctl enable vncserver@:1.service &> /dev/null
echo " Done"
echo -n "Downloading TRiBot and OSBuddy..."
sudo mkdir /home/$name/Desktop/ &> /dev/null
sudo mkdir /home/$name/Desktop/Bots/ &> /dev/null
cd /home/$name/Desktop/
sudo chown $name Bots
wget --no-check-cert -O /home/$name/Desktop/Bots/TRiBot_Loader.jar https://tribot.org/bin/TRiBot_Loader.jar &> /dev/null
wget --no-check-cert -O /home/$name/Desktop/Bots/OSBuddy.jar http://cdn.rsbuddy.com/live/f/loader/OSBuddy.jar?x=10 &> /dev/null
cd /home/$name/Desktop
sudo chown $name Bots
sudo chmod 777 Bots
echo " Done"
echo -n "Creating Screen Resolution Change Shortcuts..."
cd /home/$name/Desktop
mkdir "Screen Resolution Change Shortcuts" &> /dev/null
sudo chown $name S*
cd "Screen Resolution Change Shortcuts"
echo 'xrandr -s 640x480' >> "Change to 640x480.sh"
echo 'xrandr -s 800x600' >> "Change to 800x600.sh"
echo 'xrandr -s 1024x768' >> "Change to 1024x768.sh"
echo 'xrandr -s 1280x720' >> "Change to 1280x720.sh"
echo 'xrandr -s 1280x800' >> "Change to 1280x800.sh"
echo 'xrandr -s 1280x960' >> "Change to 1280x960.sh"
echo 'xrandr -s 1280x1024' >> "Change to 1280x1024.sh"
echo 'xrandr -s 1360x768' >> "Change to 1360x768.sh"
echo 'xrandr -s 1400x1050' >> "Change to 1400x1050.sh"
echo 'xrandr -s 1680x1050' >> "Change to 1680x1050.sh"
echo 'xrandr -s 1680x1200' >> "Change to 1680x1200.sh"
echo 'xrandr -s 1920x1080' >> "Change to 1920x1080.sh"
echo 'xrandr -s 1920x1200' >> "Change to 1920x1200.sh"
cd /home/$name/Desktop
sudo chown $name S*
sudo chmod -R 777 S*
echo " Done"
echo -n "Setting up Java..."
cd
# wget --no-check-cert --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u102-b14/jdk-8u102-linux-i586.rpm" -O jdk-8u102-linux-i586.rpm &> /dev/null
wget --no-check-cert "https://mirror.its.sfu.ca/mirror/CentOS-Third-Party/NSG/common/i386/jdk-8u102-linux-i586.rpm" -O jdk-8u102-linux-i586.rpm &> /dev/null
sudo yum -y localinstall --nogpgcheck jdk-8u102-linux-i586.rpm &> /dev/null
sudo rm ~/jdk-8u102-linux-i586.rpm
echo " Done"
echo -n "Housekeeping, like allowing .jar double clicks..."
mkdir /usr/lib/mozilla
mkdir /usr/lib/mozilla/plugins
update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/local/firefox/firefox 100 &> /dev/null
update-alternatives --install /usr/lib/mozilla/plugins/libjavaplugin.so mozilla-javaplugin.so /usr/java/jdk1.8.0_102/jre/lib/i386/libnpjp2.so 1000 &> /dev/null
update-alternatives --set "mozilla-javaplugin.so" "/usr/java/jdk1.8.0_102/jre/lib/i386/libnpjp2.so" &> /dev/null
echo "X-GNOME-Autostart-enabled=false" >> /etc/xdg/autostart/gpk-update-icon.desktop
echo "[Desktop Entry]" >> JB-java-jdk8.desktop
echo "Encoding=UTF-8" >> JB-java-jdk8.desktop
echo "Name=Oracle Java 8 Runtime" >> JB-java-jdk8.desktop
echo "Comment=Oracle Java 8 Runtime" >> JB-java-jdk8.desktop
echo "Exec=/usr/java/jdk1.8.0_102/jre/bin/java -jar %f" >> JB-java-jdk8.desktop
echo "Terminal=false" >> JB-java-jdk8.desktop
echo "Type=Application" >> JB-java-jdk8.desktop
echo "Icon=oracle_java8" >> JB-java-jdk8.desktop
echo "MimeType=application/x-java-archive;application/java-archive;application/x-jar;" >> JB-java-jdk8.desktop
echo "NoDisplay=false" >> JB-java-jdk8.desktop
sudo mv JB-java-jdk8.desktop /usr/share/applications/JB-java-jdk8.desktop
mkdir /home/$name/.local/share/applications &> /dev/null
echo "[Added Associations]" >> /home/$name/.local/share/applications/mimeapps.list
echo "application/x-java-archive=JB-java-jdk8.desktop;" >> /home/$name/.local/share/applications/mimeapps.list
sudo chown -R $name /home/$name
echo " Done"