#!/bin/bash

name=$1
sshport=$2
vncport=$3
sshpassword=$4
vncpassword=$5
echo -n "Installing updates..."
apt-get update &> /dev/null
echo " Done"
echo -n "Installing required packages..."
apt-get -y install sudo wget nano locales debconf-utils xauth libxslt1.1 netselect-apt &> /dev/null
wget --no-check-cert 'https://raw.githubusercontent.com/iFluffee/Fluffees-Server-Setup/master/Debian/Debian-8/Keyboard_settings.conf' &> /dev/null
debconf-set-selections < Keyboard_settings.conf &> /dev/null
apt-get install -y keyboard-configuration &> /dev/null
dpkg-reconfigure keyboard-configuration -f noninteractive &> /dev/null
sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
echo 'LANG="en_US.UTF-8"'>/etc/default/locale
echo "export LC_ALL=en_US.UTF-8" >> /root/.bashrc
echo "export LANG=en_US.UTF-8" >> /root/.bashrc
echo "export LANGUAGE=en_US.UTF-8" >> /root/.bashrc
source ~/.bashrc &> /dev/null
dpkg-reconfigure --frontend=noninteractive locales &> /dev/null
update-locale LANG=en_US.UTF-8 &> /dev/null
sudo netselect-apt &> /dev/null
mv -f sources.list /etc/apt/
apt-get update &> /dev/null
echo " Done"
echo -n "Creating the user..."
name=${name,,} &> /dev/null
sudo adduser $name --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password &> /dev/null
echo "$name:$sshpassword" | sudo chpasswd
sudo gpasswd -a $name sudo &> /dev/null
sudo gpasswd -a $name netdev &> /dev/null
echo " Done"
echo -n "Setting up SSH..."
sed -i "s/Port 22/Port $sshport/g" /etc/ssh/sshd_config
echo "AllowUsers $name root" >> /etc/ssh/sshd_config
sed -i "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
chmod 600 /etc/ssh/sshd_config &> /dev/null
service ssh restart &> /dev/null
echo " Done"
echo -n "Installing LXDE..."
apt-get -y install xorg lxde lxtask &> /dev/null
echo " Done"
echo -n "Installing TightVNC 1.3.10 (Non broken version)..."
sudo apt-get install -y xorg-dev libjpeg62-turbo-dev zlib1g-dev build-essential xutils-dev &> /dev/null
wget --no-check-cert http://www.tightvnc.com/download/1.3.10/tightvnc-1.3.10_unixsrc.tar.gz &> /dev/null
tar xzf tightvnc-1.3.10_unixsrc.tar.gz &> /dev/null
cd vnc_unixsrc &> /dev/null
xmkmf &> /dev/null
make World &> /dev/null
cd Xvnc &> /dev/null
./configure &> /dev/null
make &> /dev/null
cd .. &> /dev/null
./vncinstall /usr/local/bin /usr/local/man &> /dev/null
sed -i -r '/unix\/:7100";/a $fontPath = join ',',qw(' /usr/local/bin/vncserver
sed -i "s/join ,,qw/join ',,qw/g" /usr/local/bin/vncserver
sed -i "s/join ',,qw/join ',',qw/g" /usr/local/bin/vncserver
sed -i /',qw(/a /usr/share/fonts/X11/misc' /usr/local/bin/vncserver
sed -i '/\/X11\/misc/a /usr/share/fonts/X11/100dp2i/:unscaled' /usr/local/bin/vncserver
sed -i '/\/usr\/share\/fonts\/X11\/100dp2i\/\:unscaled/a /usr/share/fonts/X11/75dp2i/:unscaled' /usr/local/bin/vncserver
sed -i '/\/usr\/share\/fonts\/X11\/75dp2i\/\:unscaled/a /usr/share/fonts/X11/Type1' /usr/local/bin/vncserver
sed -i '/\/usr\/share\/fonts\/X11\/Type1/a /usr/share/fonts/X11/100dpi' /usr/local/bin/vncserver
sed -i '/\/usr\/share\/fonts\/X11\/100dpi/a /usr/share/fonts/X11/75dpi' /usr/local/bin/vncserver
sed -i '/\/usr\/share\/fonts\/X11\/75dpi/a );' /usr/local/bin/vncserver
sed -i "s/75dp2i/75dpi/g" /usr/local/bin/vncserver
sed -i "s/100dp2i/100dpi/g" /usr/local/bin/vncserver
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
su  - $name -c "vncserver" &> /dev/null
su  - $name -c "vncserver -kill :1" &> /dev/null
sed -i "s/xterm -geometry 80x24+10+10 -ls -title \"\$VNCDESKTOP Desktop\" \&//g" /home/$name/.vnc/xstartup
sed -i "s/twm/startlxde/g" /home/$name/.vnc/xstartup
su  - $name -c "vncserver" &> /dev/null
su  - $name -c "vncserver -kill :1" &> /dev/null
cd /usr/local/bin/
wget --no-check-cert 'https://raw.githubusercontent.com/iFluffee/Fluffees-Server-Setup/master/Debian/Debian-8/myvncserver' &> /dev/null
sudo chown $name myvncserver &> /dev/null
sudo chmod +x /usr/local/bin/myvncserver &> /dev/null
cd /lib/systemd/system/
wget --no-check-cert 'https://raw.githubusercontent.com/iFluffee/Fluffees-Server-Setup/master/Debian/Debian-8/myvncserver.service' &> /dev/null
sed -i "s/User=vnc/User=$name/g" /lib/systemd/system/myvncserver.service
sudo systemctl daemon-reload &> /dev/null
sudo systemctl enable myvncserver.service &> /dev/null
sudo update-rc.d tightvncserver defaults &> /dev/null
echo " Done"
echo -n "Downloading TRiBot and OSBuddy..."
sudo mkdir /home/$name/Desktop/ &> /dev/null
sudo mkdir /home/$name/Desktop/Bots/ &> /dev/null
cd /home/$name/Desktop/
sudo chown $name Bots &> /dev/null
wget --no-check-cert -O /home/$name/Desktop/Bots/TRiBot_Loader.jar https://tribot.org/bin/TRiBot_Loader.jar &> /dev/null
wget --no-check-cert -O /home/$name/Desktop/Bots/OSBuddy.jar http://cdn.rsbuddy.com/live/f/loader/OSBuddy.jar?x=10 &> /dev/null
cd /home/$name/Desktop
sudo chown $name Bots &> /dev/null
sudo chmod 777 Bots &> /dev/null
echo " Done"
echo -n "Setting up Java..."
cd
wget --no-check-cert --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u102-b12/jdk-8u102-linux-i586.tar.gz" -O jdk-8u102-linux-i586.tar.gz &> /dev/null
tar -zxf jdk-8u102-linux-i586.tar.gz &> /dev/null
mkdir /usr/lib/jvm
mkdir /usr/lib/jvm/oracle_jdk8
mv /root/jdk1.8.0_102/* /usr/lib/jvm/oracle_jdk8 &> /dev/null
sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/oracle_jdk8/jre/bin/java 2000 &> /dev/null
sudo update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/oracle_jdk8/bin/javac 2000 &> /dev/null
echo "export J2SDKDIR=/usr/lib/jvm/oracle_jdk8" >> oraclejdk.sh
echo "export J2REDIR=/usr/lib/jvm/oracle_jdk8/jre" >> oraclejdk.sh
echo "export PATH=$PATH:/usr/lib/jvm/oracle_jdk8/bin:/usr/lib/jvm/oracle_jdk8/db/bin:/usr/lib/jvm/oracle_jdk8/jre/bin" >> oraclejdk.sh
echo "export JAVA_HOME=/usr/lib/jvm/oracle_jdk8" >> oraclejdk.sh
echo "export DERBY_HOME=/usr/lib/jvm/oracle_jdk8/db" >> oraclejdk.sh
sudo mv oraclejdk.sh /etc/profile.d/oraclejdk.sh
chmod 777 /etc/profile.d/oraclejdk.sh
source /etc/profile.d/oraclejdk.sh
echo " Done"
echo -n "Installing Firefox x86..."
cd /usr/local
wget --no-check-cert -O firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux&lang=en-US" &> /dev/null
tar xvjf firefox.tar.bz2 &> /dev/null
ln -s /usr/local/firefox/firefox /usr/bin/firefox &> /dev/null
update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/local/firefox/firefox 100 &> /dev/null
echo " Done"
echo -n "Housekeeping, like allowing .jar double clicks..."
apt-get remove -y xscreensaver &> /dev/null
mkdir /home/$name/.local/
mkdir /home/$name/.local/share/
mkdir /home/$name/.local/share/applications/
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
echo "[Added Associations]" >> /home/$name/.local/share/applications/mimeapps.list
echo "application/zip=JB-java-jdk8.desktop;" >> /home/$name/.local/share/applications/mimeapps.list
echo "" >> /home/$name/.local/share/applications/mimeapps.list
echo "[Default Applications]" >> /home/$name/.local/share/applications/mimeapps.list
echo "application/zip=JB-java-jdk8.desktop" >> /home/$name/.local/share/applications/mimeapps.list
chmod 644 /home/$name/.local/share/applications/mimeapps.list
sed -i "s/NoDisplay=true/NoDisplay=false/g" /usr/share/applications/JB-java-jdk8.desktop
sed -i "s/$vncPort = 5900/$vncPort = $vncport - 1/g" /usr/local/bin/vncserver
sed -i "s/sockaddr_in(5900/sockaddr_in($vncport - 1/g" /usr/local/bin/vncserver
sudo systemctl start myvncserver.service &> /dev/null
sudo chown -R $name /home/$name
echo " Done"