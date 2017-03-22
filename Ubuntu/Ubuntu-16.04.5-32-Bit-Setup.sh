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
apt-get -y install sudo wget nano libxslt1.1 &> /dev/null
echo " Done"
echo -n "Creating the user..."
name=${name,,} &> /dev/null
sudo adduser $name --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password &> /dev/null
echo "$name:$sshpassword" | sudo chpasswd &> /dev/null
sudo adduser $name sudo &> /dev/null
echo " Done"
echo -n "Setting up SSH..."
sed -i "s/Port 22/Port $sshport/g" /etc/ssh/sshd_config &> /dev/null
echo "AllowUsers $name root" >> /etc/ssh/sshd_config &> /dev/null
sed -i "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config &> /dev/null
chmod 600 sshd_config &> /dev/null
service ssh restart &> /dev/null
echo " Done"
echo -n "Installing LXDE..."
apt-get -y install xorg lxde lxtask &> /dev/null
echo " Done"
echo -n "Installing TightVNC 1.3.10 (Non broken version)..."
sudo apt-get install -y xorg-dev libjpeg62-dev zlib1g-dev build-essential xutils-dev &> /dev/null
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
sed -i -r '/unix\/:7100";/a $fontPath = join ',',qw(' /usr/local/bin/vncserver &> /dev/null
sed -i "s/join ,,qw/join ',,qw/g" /usr/local/bin/vncserver &> /dev/null
sed -i "s/join ',,qw/join ',',qw/g" /usr/local/bin/vncserver &> /dev/null
sed -i /',qw(/a /usr/share/fonts/X11/misc' /usr/local/bin/vncserver &> /dev/null
sed -i '/\/X11\/misc/a /usr/share/fonts/X11/100dp2i/:unscaled' /usr/local/bin/vncserver &> /dev/null
sed -i '/\/usr\/share\/fonts\/X11\/100dp2i\/\:unscaled/a /usr/share/fonts/X11/75dp2i/:unscaled' /usr/local/bin/vncserver &> /dev/null
sed -i '/\/usr\/share\/fonts\/X11\/75dp2i\/\:unscaled/a /usr/share/fonts/X11/Type1' /usr/local/bin/vncserver &> /dev/null
sed -i '/\/usr\/share\/fonts\/X11\/Type1/a /usr/share/fonts/X11/100dpi' /usr/local/bin/vncserver &> /dev/null
sed -i '/\/usr\/share\/fonts\/X11\/100dpi/a /usr/share/fonts/X11/75dpi' /usr/local/bin/vncserver &> /dev/null
sed -i '/\/usr\/share\/fonts\/X11\/75dpi/a );' /usr/local/bin/vncserver &> /dev/null
sed -i "s/75dp2i/75dpi/g" /usr/local/bin/vncserver &> /dev/null
sed -i "s/100dp2i/100dpi/g" /usr/local/bin/vncserver &> /dev/null
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
sudo chown root:root /etc/init.d/tightvncserver &> /dev/null
sudo chmod 755 /etc/init.d/tightvncserver &> /dev/null
sudo /etc/init.d/tightvncserver start &> /dev/null
sudo update-rc.d tightvncserver defaults &> /dev/null
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
echo -n "Setting up Java..."
echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list &> /dev/null
echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list &> /dev/null
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 &> /dev/null
apt-get update &> /dev/null
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
apt-get -y install oracle-java8-installer &> /dev/null
sudo apt-get -y install oracle-java8-set-default &> /dev/null
chmod 777 /usr/lib/jvm/java-8-oracle/jre/lib/security/java.policy &> /dev/null
cd /usr/local
echo " Done"
echo -n "Installing Firefox x86..."
wget --no-check-cert -O firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux&lang=en-US" &> /dev/null
tar xvjf firefox.tar.bz2 &> /dev/null
ln -s /usr/local/firefox/firefox /usr/bin/firefox &> /dev/null
update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/local/firefox/firefox 100 &> /dev/null
apt-get remove -y xscreensaver &> /dev/null
echo " Done"
echo -n "Housekeeping, like allowing .jar double clicks..."
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
sudo wget --no-check-cert 'https://raw.githubusercontent.com/iFluffee/Fluffees-Server-Setup/master/Ubuntu/xstartup.txt' &> /dev/null
sudo mv xstartup.txt /etc/init.d/xstartup
sudo wget --no-check-cert 'https://raw.githubusercontent.com/iFluffee/Fluffees-Server-Setup/master/Ubuntu/tightvncserver.txt' &> /dev/null
sudo mv tightvncserver.txt /etc/init.d/tightvncserver
sed -i "s/bots/$name/g" /etc/init.d/tightvncserver
sudo chown root:root /etc/init.d/tightvncserver
sudo chmod 755 /etc/init.d/tightvncserver
sudo /etc/init.d/tightvncserver start &> /dev/null
sudo update-rc.d tightvncserver defaults &> /dev/null
sed -i "s/KDE;/KDE;LXDE/g" /etc/xdg/autostart/lxpolkit.desktop
sudo chown -R $name /home/$name
echo " Done"