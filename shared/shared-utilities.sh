#!/bin/bash

TIGERVNC_LINK="https://dl.bintray.com/tigervnc/stable/"
BASE_JAVA="https://www.oracle.com"
JAVA_DOWNLOAD_PAGE="/technetwork/java/javase/downloads/index.html"

# Determines where the output of commands should be piped
# @param $1 - boolean flag to indicate verbosity, meaning output is discarded
# @return String containing the location where command output should be piped
function determine_output() {
  if [[ "$1" == true ]] ; then
    echo "/dev/tty"
  else
    echo "/dev/null"
  fi
}

# Connects to the TigerVNC bintray and pulls the latest version number for your bit type
# @param $1 - boolean flag to indicate whether or not to run the function in verbose mode
# @param $2 - Boolean indicating whether or not the OS is 64 bit
# @return Name of the package to download
function get_vnc_version() {
  output=$(determine_output $1)
  if [[ "$1" == 64 ]] ; then
    x64="!"
  else
    x64=""
  fi

  wget -O tiger.txt ${TIGERVNC_LINK} &> $output
  sed -i "/.*tigervnc-[1-9].*86.*/!d" tiger.txt
  sed -i "/.*.tar.gz.*/!d" tiger.txt
  sed -i "/.*x86.*/${x64}d" tiger.txt
  sed -i "s/.*rel=\"nofollow\">\(.*\)<\/a>.*/\1/" tiger.txt
  echo $(cat tiger.txt | tail -1 && rm -f tiger.txt)
}

# Creates the tiger vnc init.d service
# @param $1 - String where command output will be sent
# @param $2 - Name of the user to run the VNC under
# @param $3 - String containing the name of the operating system (CentOS, Debian or Ubuntu)
# @return None
function setup_vnc_initd_service() {
  output=$1
  name=$2
  operating_system=$3

  wget -O /etc/init.d/vncserver https://bitbucket.org/teamfluffee/fluffees-server-setup/raw/add-shared-functions/shared/tigervnc/vncserver-initd.service
  sed -i "s/user_name/$name/g" /etc/init.d/vncserver
  chmod +x /etc/init.d/vncserver
  if [ ${operating_system} = "centos" ]; then
    echo "service vncserver start" >> /etc/rc.d/rc.local
    chmod +x /etc/rc.d/rc.local
  fi
  update-rc.d vncserver defaults
}

# Creates the tiger vnc systemd service
# @param $1 - boolean flag indicating verbosity of function
# @param $2 - Name of the user to run the VNC under
# @return None
function setup_vnc_systemd_service() {
  echo ""
}

# @Deprecated
# Parses the oracle page to find the link to the JDK 8 downloads
# @param $1 - String where command output will be sent
# @return Extension to the base oracle link where the JDK 8 downloads are found
function get_jdk_downloads_page() {
  output=$1
  wget -O java_downloads.txt ${BASE_JAVA}${JAVA_DOWNLOAD_PAGE} &> $output
  sed -i "/.*jdk8-downloads.*/!d" java_downloads.txt
  sed -i "s/.*href=\"\(.*\)\"><img.*/\1/" java_downloads.txt
  echo $(cat java_downloads.txt | tail -1 && rm -f java_downloads.txt)
}

# Parses the JDK downloads page to find the download link
# @param $1 - String where command output will be sent
# @param $2 - Bit type of the operating system as int, 32 or 64
# @param $3 - File extension (rpm or tar.gz)
# @return The download link for the JDK
function get_jdk_download_link() {
  output=$1
  if [[ $2 == 32 ]] ; then
    bit_type="i586"
  else
    bit_type="x64"
  fi

  file_extension=$3

  link=$(curl -s https://api.github.com/repos/frekele/oracle-java/releases/latest | grep "browser_download_url.*jdk.*linux-${bit_type}.*${file_extension}\"" | cut -d : -f 2,3 | sed -e 's/^ "//' -e 's/"$//')
  echo ${link}
}

# Sets up the configuration files for Openbox, Fbpanel and PCManFM
# @param $1 - boolean flag to indicate whether or not to run the function in verbose mode
# @param $2 - Name of the user account to setup
function setup_desktop() {
  output=$(determine_output $1)
  name=$2

  mkdir -p /home/$name/.config/openbox &> $output
  mkdir -p /home/$name/.config/fbpanel &> $output
  mkdir -p /home/$name/.config/pcmanfm/default &> $output

  wget -O /home/$name/.config/openbox/autostart https://bitbucket.org/teamfluffee/fluffees-server-setup/raw/add-shared-functions/shared/desktop/openbox-autostart.txt &> $output
  wget -O /home/$name/.config/fbpanel/default https://bitbucket.org/teamfluffee/fluffees-server-setup/raw/add-shared-functions/shared/desktop/fbpanel-default-config.txt &> $output
  wget -O /home/$name/.config/pcmanfm/default/desktop-items-0.conf https://bitbucket.org/teamfluffee/fluffees-server-setup/raw/add-shared-functions/shared/desktop/pcmanfm-desktop-items.txt &> $output
  wget -O /home/$name/.config/pcmanfm/default/pcmanfm.conf https://bitbucket.org/teamfluffee/fluffees-server-setup/raw/add-shared-functions/shared/desktop/pcmanfm-default-config.txt &> $output
  wget -O /home/$name/.gtkrc-2.0 https://bitbucket.org/teamfluffee/fluffees-server-setup/raw/add-shared-functions/shared/desktop/gtk-settings.txt &> $output
  sed -i "s/user_name/$name/g" /home/$name/.gtkrc-2.0
  chown -R ${name}:${name} /home/${name}/*
  chown -R ${name}:${name} /home/${name}/.*
  update-alternatives --install /usr/bin/x-file-manager x-file-manager /usr/bin/pcmanfm 100 &> $output
  update-alternatives --install /usr/bin/x-terminal x-terminal /usr/bin/xterm 100 &> $output
  update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/firefox 100 &> $output
  dbus-uuidgen > /var/lib/dbus/machine-id
}

# Creates bot folder, downloads TRiBot and OSBuddy
# @param $1 - boolean flag to indicate whether or not to run the function in verbose mode
# @param $2 - Name of account where bots should be installed
# $return - None
function setup_bots() {
  output=$(determine_output $1) 
  name=$2

  mkdir /home/$name/Desktop/ &> $output
  mkdir /home/$name/Desktop/Bots/ &> $output
  wget --no-check-cert -O /home/$name/Desktop/Bots/TRiBot_Loader.jar https://tribot.org/bin/TRiBot_Loader.jar &> $output
  wget --no-check-cert -O /home/$name/Desktop/Bots/OSBuddy.jar http://cdn.rsbuddy.com/live/f/loader/OSBuddy.jar?x=10 &> $output
  chown $name /home/$name/Desktop/Bots
  chmod +x /home/$name/Desktop/Bots #TODO: Just give run permissions to all .jars
}


# Creates shortcuts on the desktop to allow quickly changing VNC resolution
# @param $1 - Name of the user with the desktop to create the shortcuts on
# @return - None
function create_resolution_change() {
  name=$1

  mkdir -p "/home/$name/Desktop/Change-Screen-Resolution"
  chown $name "/home/$name/Desktop/Change-Screen-Resolution"
  echo 'xrandr -s 640x480' >> "/home/$name/Desktop/Change-Screen-Resolution/Change-to-640x480.sh"
  echo -e '#!/bin/bash\n\nxrandr -s 800x600' >> "/home/$name/Desktop/Change-Screen-Resolution/Change-to-800x600.sh"
  echo -e '#!/bin/bash\n\nxrandr -s 1024x768' >> "/home/$name/Desktop/Change-Screen-Resolution/Change-to-1024x768.sh"
  echo -e '#!/bin/bash\n\nxrandr -s 1280x720' >> "/home/$name/Desktop/Change-Screen-Resolution/Change-to-1280x720.sh"
  echo -e '#!/bin/bash\n\nxrandr -s 1280x800' >> "/home/$name/Desktop/Change-Screen-Resolution/Change-to-1280x800.sh"
  echo -e '#!/bin/bash\n\nxrandr -s 1280x960' >> "/home/$name/Desktop/Change-Screen-Resolution/Change-to-1280x960.sh"
  echo -e '#!/bin/bash\n\nxrandr -s 1280x1024' >> "/home/$name/Desktop/Change-Screen-Resolution/Change-to-1280x1024.sh"
  echo -e '#!/bin/bash\n\nxrandr -s 1360x768' >> "/home/$name/Desktop/Change-Screen-Resolution/Change-to-1360x768.sh"
  echo -e '#!/bin/bash\n\nxrandr -s 1400x1050' >> "/home/$name/Desktop/Change-Screen-Resolution/Change-to-1400x1050.sh"
  echo -e '#!/bin/bash\n\nxrandr -s 1680x1050' >> "/home/$name/Desktop/Change-Screen-Resolution/Change-to-1680x1050.sh"
  echo -e '#!/bin/bash\n\nxrandr -s 1680x1200' >> "/home/$name/Desktop/Change-Screen-Resolution/Change-to-1680x1200.sh"
  echo -e '#!/bin/bash\n\nxrandr -s 1920x1080' >> "/home/$name/Desktop/Change-Screen-Resolution/Change-to-1920x1080.sh"
  echo -e '#!/bin/bash\n\nxrandr -s 1920x1200' >> "/home/$name/Desktop/Change-Screen-Resolution/Change-to-1920x1200.sh"
  chmod -R 754 "/home/$name/Desktop/Change-Screen-Resolution/"
}

# Allows jar files to be double clicked to run
# @param $1 - Name of the user with the desktop to create the shortcuts on
# @return - None
function enable_jar_doubleclick() {
  name=$1
  java_directory=$(readlink -f /etc/alternatives/java)
  
  echo "[Desktop Entry]" >> JB-java-jdk8.desktop
  echo "Encoding=UTF-8" >> JB-java-jdk8.desktop
  echo "Name=Oracle Java 8 Runtime" >> JB-java-jdk8.desktop
  echo "Comment=Oracle Java 8 Runtime" >> JB-java-jdk8.desktop
  echo "Exec=${java_directory} -jar %f" >> JB-java-jdk8.desktop
  echo "Terminal=false" >> JB-java-jdk8.desktop
  echo "Type=Application" >> JB-java-jdk8.desktop
  echo "Icon=oracle_java8" >> JB-java-jdk8.desktop
  echo "MimeType=application/x-java-archive;application/java-archive;application/x-jar;" >> JB-java-jdk8.desktop
  echo "NoDisplay=false" >> JB-java-jdk8.desktop
  mv JB-java-jdk8.desktop /usr/share/applications/JB-java-jdk8.desktop
  mkdir -p /home/$name/.local/share/applications
  echo "[Added Associations]" >> /home/$name/.local/share/applications/mimeapps.list
  echo "application/x-java-archive=JB-java-jdk8.desktop;" >> /home/$name/.local/share/applications/mimeapps.list
}

# Downloads the latest TigerVNC bin and installs it
# @param $1 - boolean flag to indicate whether or not to run the function in verbose mode
# @param $2 - Bit type of the operating system currently running
function install_vnc() {
  output=$(determine_output $1)
  vnc_package=$(get_vnc_version $2)
  wget -O tiger_vnc.tar.gz ${TIGERVNC_LINK}${vnc_package}
  tar -zxf tiger_vnc.tar.gz --strip 1 -C /  &> $output
  rm -f tiger_vnc.tar.gz
}

# Sets up tiger vnc for practical use
# @param $1 - boolean flag to indicate whether or not to run the function in verbose mode
# @param $2 - Port number to run the vnc server on
# @param $3 - Name of user to run VNC under
# @param $4 - Password string to use for logging in to VNC
# @param $5 - Name of the operating system currently running on (centos, debian or ubuntu)
# @return - None
function setup_vnc() {
  output=$(determine_output $1)
  port=$2
  name=$3
  password=$4
  operating_system=$5

  mkdir /home/$name/.vnc
  echo $password >/home/$name/.vnc/file #TODO: See if we can pipe those together.
  vncpasswd -f </home/$name/.vnc/file >/home/$name/.vnc/passwd
  rm /home/$name/.vnc/file
  chown $name /home/$name/.vnc &> $output
  chown $name /home/$name/.vnc/passwd &> $output
  chmod 600 /home/$name/.vnc/passwd &> $output
  su  - $name -c "vncserver" &> $output
  su  - $name -c "vncserver -kill :1" &> $output
  echo "VNCSERVERS=\"1:$name\"" >> /etc/sysconfig/vncservers
  echo "VNCSERVERARGS[1]=\"-geometry 1024x786\"" >> /etc/sysconfig/vncservers
  echo -e '#!/bin/bash\n\nopenbox-session &' > "/home/$name/.vnc/xstartup"
  chmod +x /home/$name/.vnc/xstartup
  sed -i "s/$vncPort = 5900/$vncPort = $port - 1/g" /usr/bin/vncserver
  if [ ${operating_system} = "centos" ]; then
    firewall-cmd --zone=public --add-port=$port/tcp --permanent &> $output
    firewall-cmd --reload &> $output
  fi
  setup_vnc_initd_service $output $name
  service vncserver start &> $output
}