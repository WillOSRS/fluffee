#!/bin/bash

name=$1
sshport=$2
vncport=$3
sshpassword=$4
vncpassword=$5
echo -n "Installing updates..."
apt-get update
echo " Done"
echo -n "Installing required packages..."
apt-get -y install sudo wget nano libxslt1.1
wget --no-check-cert 'https://raw.githubusercontent.com/iFluffee/Fluffees-Server-Setup/master/Debian/Debian-7/Keyboard_settings.conf'
debconf-set-selections < Keyboard_settings.conf
apt-get install -y keyboard-configuration
dpkg-reconfigure keyboard-configuration -f noninteractive
wget --no-check-certificate https://github.com/brodock/apt-select/releases/download/0.1.0/apt-select_0.1.0-0_all.deb
apt-get install -y python-bs4
dpkg -i apt-select_0.1.0-0_all.deb
apt-select
mv -f sources.list /etc/apt/
apt-get update
echo " Done"
echo -n "Creating the user..."
name=${name,,}
sudo adduser $name --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
echo "$name:$sshpassword" | sudo chpasswd
sudo adduser $name sudo
echo " Done"
echo -n "Setting up SSH..."
sed -i "s/Port 22/Port $sshport/g" /etc/ssh/sshd_config
echo "AllowUsers $name root" >> /etc/ssh/sshd_config
sed -i "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
chmod 600 /etc/ssh/sshd_config
service ssh restart
DEBIAN_FRONTEND=noninteractive apt-get -yq install xorg
echo " Done"
echo -n "Installing LXDE..."
DEBIAN_FRONTEND=noninteractive apt-get -yq install lxtask
DEBIAN_FRONTEND=noninteractive apt-get -yq install lxde
echo " Done"
echo -n "Installing TigerVNC (Non broken version)..."
wget --no-check-certificate "https://bintray.com/tigervnc/stable/download_file?file_path=tigervnc-1.8.0.x86_64.tar.gz" -O tigervnc-1.8.0.x86_64.tar.gz
tar -zxf tigervnc-1.8.0.x86_64.tar.gz
cp -far ~/tigervnc-1.8.0.x86_64/usr/* /usr/local
rm -rf tigervnc-1.8.0.x86_64.tar.gz
rm -rf tigervnc-1.8.0.x86_64
echo " Done"
echo -n "Setting up VNC..."
mkdir /home/$name/.vnc
echo $vncpassword >/home/$name/.vnc/file
vncpasswd -f </home/$name/.vnc/file >/home/$name/.vnc/passwd
chown $name /home/$name/.vnc
chown $name /home/$name/.vnc/passwd
chgrp $name /home/$name/.vnc
chgrp $name /home/$name/.vnc/passwd
chmod 600 /home/$name/.vnc/passwd
su  - $name -c "vncserver"
su  - $name -c "vncserver -kill :1"
sed -i "s/xterm -geometry 80x24+10+10 -ls -title \"\$VNCDESKTOP Desktop\" \&//g" /home/$name/.vnc/xstartup
sed -i "s/twm/startlxde/g" /home/$name/.vnc/xstartup
su  - $name -c "vncserver"
su  - $name -c "vncserver -kill :1"
sudo wget --no-check-cert 'https://raw.githubusercontent.com/iFluffee/Fluffees-Server-Setup/master/Ubuntu/tigervncserver.txt'
sudo mv tigervncserver.txt /etc/init.d/tigervncserver
sed -i "s/bots/$name/g" /etc/init.d/tigervncserver
sudo chown root:root /etc/init.d/tigervncserver
sudo chmod 755 /etc/init.d/tigervncserver
sudo /etc/init.d/tigervncserver start
sudo update-rc.d tigervncserver defaults
echo " Done"
echo -n "Downloading TRiBot and OSBuddy..."
sudo mkdir /home/$name/Desktop/
sudo mkdir /home/$name/Desktop/Bots/
cd /home/$name/Desktop/
sudo chown $name Bots
wget --no-check-cert -O /home/$name/Desktop/Bots/TRiBot_Loader.jar https://tribot.org/bin/TRiBot_Loader.jar
wget --no-check-cert -O /home/$name/Desktop/Bots/OSBuddy.jar http://cdn.rsbuddy.com/live/f/loader/OSBuddy.jar?x=10
cd /home/$name/Desktop
sudo chown -R $name Bots
sudo chmod -R 777 Bots
echo " Done"
echo -n "Creating Screen Resolution Change Shortcuts..."
cd /home/$name/Desktop
mkdir "Screen Resolution Change Shortcuts"
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
sudo chown -R $name S*
sudo chmod -R 777 S*
echo " Done"
echo -n "Setting up Java..."
cd
# wget --no-check-cert --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u102-b14/jdk-8u102-linux-x64.tar.gz" -O jdk-8u102-linux-x64.tar.gz
wget --no-check-cert "http://mirrors.linuxeye.com/jdk/jdk-8u102-linux-x64.tar.gz" -O jdk-8u102-linux-x64.tar.gz
tar -zxf jdk-8u102-linux-x64.tar.gz
mkdir /usr/lib/jvm
mkdir /usr/lib/jvm/oracle_jdk8
mv /root/jdk1.8.0_102/* /usr/lib/jvm/oracle_jdk8
sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/oracle_jdk8/jre/bin/java 2000
sudo update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/oracle_jdk8/bin/javac 2000
echo "export J2SDKDIR=/usr/lib/jvm/oracle_jdk8" >> oraclejdk.sh
echo "export J2REDIR=/usr/lib/jvm/oracle_jdk8/jre" >> oraclejdk.sh
echo "export PATH=$PATH:/usr/lib/jvm/oracle_jdk8/bin:/usr/lib/jvm/oracle_jdk8/db/bin:/usr/lib/jvm/oracle_jdk8/jre/bin" >> oraclejdk.sh
echo "export JAVA_HOME=/usr/lib/jvm/oracle_jdk8" >> oraclejdk.sh
echo "export DERBY_HOME=/usr/lib/jvm/oracle_jdk8/db" >> oraclejdk.sh
sudo mv oraclejdk.sh /etc/profile.d/oraclejdk.sh
chmod 777 /etc/profile.d/oraclejdk.sh
source /etc/profile.d/oraclejdk.sh
echo " Done"
echo -n "Installing Firefox x64..."
cd /usr/local
wget --no-check-cert -O firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-esr-latest&os=linux64&lang=en-US"
tar xvjf firefox.tar.bz2
ln -s /usr/local/firefox/firefox /usr/bin/firefox
mkdir /usr/lib/mozilla
mkdir /usr/lib/mozilla/plugins
update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/local/firefox/firefox 100
update-alternatives --install /usr/lib/mozilla/plugins/libjavaplugin.so mozilla-javaplugin.so /usr/lib/jvm/oracle_jdk8/jre/lib/amd64/libnpjp2.so 1000
update-alternatives --set "mozilla-javaplugin.so" "/usr/lib/jvm/oracle_jdk8/jre/lib/amd64/libnpjp2.so"
apt-get remove -y xscreensaver
echo " Done"
echo -n "Housekeeping, like allowing .jar double clicks..."
echo "X-GNOME-Autostart-enabled=false" >> /etc/xdg/autostart/gpk-update-icon.desktop
echo "[Desktop Entry]" >> JB-java-jdk8.desktop
echo "Encoding=UTF-8" >> JB-java-jdk8.desktop
echo "Name=Oracle Java 8 Runtime" >> JB-java-jdk8.desktop
echo "Comment=Oracle Java 8 Runtime" >> JB-java-jdk8.desktop
echo "Exec=/usr/bin/java -jar %f" >> JB-java-jdk8.desktop
echo "Terminal=false" >> JB-java-jdk8.desktop
echo "Type=Application" >> JB-java-jdk8.desktop
echo "Icon=oracle_java8" >> JB-java-jdk8.desktop
echo "MimeType=application/x-java-archive;application/java-archive;application/x-jar;" >> JB-java-jdk8.desktop
echo "NoDisplay=false" >> JB-java-jdk8.desktop
sudo mv JB-java-jdk8.desktop /usr/share/applications/JB-java-jdk8.desktop
mkdir /home/$name/.local/
mkdir /home/$name/.local/share/
mkdir /home/$name/.local/share/applications/
echo "[Added Associations]" >> /home/$name/.local/share/applications/mimeapps.list
echo "application/zip=JB-java-jdk8.desktop;" >> /home/$name/.local/share/applications/mimeapps.list
echo "" >> /home/$name/.local/share/applications/mimeapps.list
echo "[Default Applications]" >> /home/$name/.local/share/applications/mimeapps.list
echo "application/zip=JB-java-jdk8.desktop" >> /home/$name/.local/share/applications/mimeapps.list
chmod 644 /home/$name/.local/share/applications/mimeapps.list
sed -i "s/NoDisplay=true/NoDisplay=false/g" /usr/share/applications/JB-java-jdk8.desktop
sed -i "s/$vncPort = 5900/$vncPort = $vncport - 1/g" /usr/local/bin/vncserver
sed -i "s/sockaddr_in(5900/sockaddr_in($vncport - 1/g" /usr/local/bin/vncserver
sed -i "s/$vncPort = 5900/$vncPort = $vncport - 1/g" /usr/local/bin/vncserver
sed -i "s/sockaddr_in(5900/sockaddr_in($vncport - 1/g" /usr/local/bin/vncserver
sudo wget --no-check-cert 'https://raw.githubusercontent.com/iFluffee/Fluffees-Server-Setup/master/Ubuntu/xstartup.txt'
sudo mv xstartup.txt /etc/init.d/xstartup
sudo /etc/init.d/tigervncserver start
sudo update-rc.d tigervncserver defaults
sudo chown -R $name /home/$name
echo " Done"