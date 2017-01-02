read -p "What would you like your user account to be named? Must be lowercase " name
read -p "What port would you like to use to ssh to your server? " sshport
read -p "What port would you like to use to vnc to your server? " vncport
read -p "What would you like your ssh password to be? " sshpassword
read -p "What would you like your vnc password to be? " vncpassword
yum -y update
yum -y install epel-release nano tigervnc-server gnome-system-monitor firefox
yum -y groupinstall xfce
chkconfig vncserver on
sed -i "s/#Port 22/Port $sshport/g" /etc/ssh/sshd_config
sed -i "s/#PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
echo "" >> /etc/ssh/sshd_config
echo "AllowUsers $name root" >> /etc/ssh/sshd_config
service sshd restart
adduser $name
echo "$name:$sshpassword" | chpasswd
usermod -aG wheel $name
sed -i "s/# %wheel/%wheel/g" /etc/sudoers
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
sudo cp /lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:1.service
sudo sed -i -e 's![<]USER[>]!'"$name"'!g' /etc/systemd/system/vncserver@:1.service
sed -i "s/}/if \[ \-x \/bin\/xfce4-session \] \; then/g" /etc/X11/xinit/Xclients
echo "        exec /bin/xfce4-session" >> /etc/X11/xinit/Xclients
echo "    fi" >> /etc/X11/xinit/Xclients
echo "}" >> /etc/X11/xinit/Xclients
sed -i "s/$vncPort = 5900/$vncPort = $vncport - 1/g" /usr/bin/vncserver
mkdir /home/$name/.config/xfce4
echo "FileManager=nautilus" >> /home/$name/.config/xfce4/helpers.rc
systemctl start vncserver@:1.service
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u60-b27/jdk-8u60-linux-x64.rpm" -O jdk-8u60-linux-x64.rpm
sudo yum -y localinstall --nogpgcheck jdk-8u60-linux-x64.rpm
sudo rm ~/jdk-8u60-linux-x64.rpm
sudo mkdir /home/$name/Desktop/
sudo mkdir /home/$name/Desktop/Bots/
cd /home/$name/Desktop/
sudo chown $name Bots
wget -O /home/$name/Desktop/Bots/TRiBot_Loader.jar https://tribot.org/bin/TRiBot_Loader.jar
wget -O /home/$name/Desktop/Bots/OSBuddy.jar http://cdn.rsbuddy.com/live/f/loader/OSBuddy.jar?x=10
cd /home/$name/Desktop
sudo chown $name Bots
sudo chmod 777 Bots
echo "X-GNOME-Autostart-enabled=false" >> /etc/xdg/autostart/gpk-update-icon.desktop
echo "[Desktop Entry]" >> JB-java-jdk8.desktop
echo "Encoding=UTF-8" >> JB-java-jdk8.desktop
echo "Name=Oracle Java 8 Runtime" >> JB-java-jdk8.desktop
echo "Comment=Oracle Java 8 Runtime" >> JB-java-jdk8.desktop
echo "Exec=/usr/java/jdk1.8.0_60/jre/bin/java -jar %f" >> JB-java-jdk8.desktop
echo "Terminal=false" >> JB-java-jdk8.desktop
echo "Type=Application" >> JB-java-jdk8.desktop
echo "Icon=oracle_java8" >> JB-java-jdk8.desktop
echo "MimeType=application/x-java-archive;application/java-archive;application/x-jar;" >> JB-java-jdk8.desktop
echo "NoDisplay=false" >> JB-java-jdk8.desktop
sudo mv JB-java-jdk8.desktop /usr/share/applications/JB-java-jdk8.desktop
mkdir /home/$name/.local/share/applications
echo "[Added Associations]" >> /home/$name/.local/share/applications/mimeapps.list
echo "application/x-java-archive=JB-java-jdk8.desktop;" >> /home/$name/.local/share/applications/mimeapps.list