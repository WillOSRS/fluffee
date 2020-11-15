#!/usr/bin/env bash

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
  if [[ "$2" -eq 64 ]] ; then
    x64="!"
  else
    x64=""
  fi

  safe_download ${output} "tiger.txt" ${TIGERVNC_LINK}
  sed -i '/.*tigervnc-[1-9].*86.*/!d' tiger.txt
  sed -i '/.*\.tar\.gz.*/!d' tiger.txt
  sed -i "/.*x86.*/${x64}d" tiger.txt
  sed -i "s/.*rel=\"nofollow\">\(.*\)<\/a>.*/\1/" tiger.txt
  echo $(sort -n -t '.' -k 2 tiger.txt | tail -1 && rm -f tiger.txt)
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

  safe_download ${output} "/etc/init.d/vncserver" https://bitbucket.org/teamfluffee/fluffees-server-setup/raw/master/shared/tigervnc/vncserver-initd.service
  sed -i "s/user_name/$name/g" /etc/init.d/vncserver
  chmod +x /etc/init.d/vncserver
  if [[ ${operating_system} == "centos" ]]; then
    chkconfig vncserver on
  else
    update-rc.d vncserver defaults
  fi
}

# Parses the JDK downloads page to find the download link
# @param $1 - String where command output will be sent
# @param $2 - Bit type of the operating system as int, 32 or 64
# @param $3 - File extension (rpm or tar.gz)
# @return The download link for the JDK
function get_jdk_download_link() {
  output=$1
  if [[ $2 -eq 32 ]] ; then
    bit_type="i586"
  else
    bit_type="x64"
  fi

  file_extension=$3

  safe_download ${output} "jdk_latest.txt" "https://api.github.com/repos/frekele/oracle-java/releases/latest"

  link=$(cat "jdk_latest.txt" | grep "browser_download_url.*jdk.*linux-${bit_type}.*${file_extension}\"" | cut -d : -f 2,3 | sed -e 's/^ "//' -e 's/"$//')
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

  safe_download ${output} "/home/$name/.config/openbox/autostart" https://bitbucket.org/teamfluffee/fluffees-server-setup/raw/master/shared/desktop/openbox-autostart.txt
  safe_download ${output} "/home/$name/.config/fbpanel/default" https://bitbucket.org/teamfluffee/fluffees-server-setup/raw/master/shared/desktop/fbpanel-default-config.txt
  safe_download ${output} "/home/$name/.config/pcmanfm/default/desktop-items-0.conf" https://bitbucket.org/teamfluffee/fluffees-server-setup/raw/master/shared/desktop/pcmanfm-desktop-items.txt
  safe_download ${output} "/home/$name/.config/pcmanfm/default/pcmanfm.conf" https://bitbucket.org/teamfluffee/fluffees-server-setup/raw/master/shared/desktop/pcmanfm-default-config.txt
  safe_download ${output} "/home/$name/.gtkrc-2.0" https://bitbucket.org/teamfluffee/fluffees-server-setup/raw/master/shared/desktop/gtk-settings.txt
  sed -i "s/user_name/$name/g" /home/$name/.gtkrc-2.0
  chown -R ${name}:${name} /home/${name}/*
  chown -R ${name}:${name} /home/${name}/.*
  update-alternatives --install /usr/bin/x-file-manager x-file-manager /usr/bin/pcmanfm 100 &> $output
  update-alternatives --install /usr/bin/x-terminal x-terminal /usr/bin/xterm 100 &> $output
  update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/firefox 100 &> $output
  dbus-uuidgen > /var/lib/dbus/machine-id
}

# Creates bot folder, downloads TRiBot and OpenOSRS
# @param $1 - boolean flag to indicate whether or not to run the function in verbose mode
# @param $2 - Name of account where bots should be installed
# @return - None
function setup_bots() {
  output=$(determine_output $1)
  name=$2

  mkdir /home/$name/Desktop/ &> $output
  
  install_tribot_15 $output $name
  download_openosrs $output $name
}

# Installs TRiBot 15
# @param $1 - boolean flag indicating whether or not we want to run in verbose
# @param $2 - Name of the account being used
# @return - None
function install_tribot_15() {
  output=$(determine_output $1)
  name=$2

  mkdir -p /opt/tribot &> ${output}
  safe_download ${output} "tribot.tar.gz" http://installers.tribot.org/TRiBot-unix-latest.tar.gz
  tar -xzf tribot.tar.gz -C /opt/tribot/ --strip-components=1 &> ${output}
  chown -R ${name} /opt/tribot/*
  rm -rf tribot.tar.gz

  mkdir -p /home/${name}/.local/share/applications/
  touch /home/${name}/.local/share/applications/TRiBot.desktop

  tribot_icon_path=$(ls -ad /opt/tribot/.install4j/* | grep 2x | grep -v i4j)

  echo "[Desktop Entry]" >> "/home/${name}/.local/share/applications/TRiBot.desktop"
  echo "Encoding=UTF-8" >> "/home/${name}/.local/share/applications/TRiBot.desktop"
  echo "Version=1.0" >> "/home/${name}/.local/share/applications/TRiBot.desktop"
  echo "Type=Application" >> "/home/${name}/.local/share/applications/TRiBot.desktop"
  echo "Terminal=false" >> "/home/${name}/.local/share/applications/TRiBot.desktop"
  echo "Exec=/opt/tribot/TRiBot" >> "/home/${name}/.local/share/applications/TRiBot.desktop"
  echo "Name=TRiBot" >> "/home/${name}/.local/share/applications/TRiBot.desktop"
  echo "Icon=${tribot_icon_path}" >> "/home/${name}/.local/share/applications/TRiBot.desktop"

  cp "/home/${name}/.local/share/applications/TRiBot.desktop" "/home/${name}/Desktop"
}

# Downloads the OpenOSRS launcher from their Github by parsing the latest release page to find the newest version
# @param $1 - boolean flag to indicate whether or not to run the function in verbose mode
# @param $2 - Name of account where bots should be installed
# @return - None
function download_openosrs() {
  output=$(determine_output $1)
  name=$2
  temp_file="temp_openosrs.txt"

  safe_download ${output} ${temp_file} "https://github.com/open-osrs/launcher/releases/latest"
  sed -i '/\.jar/!d' ${temp_file}
  sed -i '/href/!d' ${temp_file}
  download_link_ending=$(cat ${temp_file} | sed -e 's/.*href=\"\(.*\)\"\ rel=.*/\1/')

  mkdir -p /home/${name}/.local/bin/openosrs/

  safe_download ${output} "OpenOSRS.jar" "https://github.com${download_link_ending}"
  mv "OpenOSRS.jar" "/home/${name}/Desktop/OpenOSRS.jar"
  chmod +x "/home/${name}/Desktop/OpenOSRS,jar"
  chown ${name} "/home/${name}/Desktop/OpenOSRS.jar"
}

# Creates shortcuts on the desktop to allow quickly changing VNC resolution
# @param $1 - Name of the user with the desktop to create the shortcuts on
# @return - None
function create_resolution_change() {
  name=$1

  mkdir -p "/home/$name/Desktop/Change-Screen-Resolution"
  chown $name "/home/$name/Desktop/Change-Screen-Resolution"
  echo 'xrandr -s 640x480' >> "/home/$name/Desktop/Change-Screen-Resolution/Change-to-640x480.sh"
  echo -e '#!/usr/bin/env bash\n\nxrandr -s 800x600' >> "/home/$name/Desktop/Change-Screen-Resolution/Change-to-800x600.sh"
  echo -e '#!/usr/bin/env bash\n\nxrandr -s 1024x768' >> "/home/$name/Desktop/Change-Screen-Resolution/Change-to-1024x768.sh"
  echo -e '#!/usr/bin/env bash\n\nxrandr -s 1280x720' >> "/home/$name/Desktop/Change-Screen-Resolution/Change-to-1280x720.sh"
  echo -e '#!/usr/bin/env bash\n\nxrandr -s 1280x800' >> "/home/$name/Desktop/Change-Screen-Resolution/Change-to-1280x800.sh"
  echo -e '#!/usr/bin/env bash\n\nxrandr -s 1280x960' >> "/home/$name/Desktop/Change-Screen-Resolution/Change-to-1280x960.sh"
  echo -e '#!/usr/bin/env bash\n\nxrandr -s 1280x1024' >> "/home/$name/Desktop/Change-Screen-Resolution/Change-to-1280x1024.sh"
  echo -e '#!/usr/bin/env bash\n\nxrandr -s 1360x768' >> "/home/$name/Desktop/Change-Screen-Resolution/Change-to-1360x768.sh"
  echo -e '#!/usr/bin/env bash\n\nxrandr -s 1400x1050' >> "/home/$name/Desktop/Change-Screen-Resolution/Change-to-1400x1050.sh"
  echo -e '#!/usr/bin/env bash\n\nxrandr -s 1680x1050' >> "/home/$name/Desktop/Change-Screen-Resolution/Change-to-1680x1050.sh"
  echo -e '#!/usr/bin/env bash\n\nxrandr -s 1680x1200' >> "/home/$name/Desktop/Change-Screen-Resolution/Change-to-1680x1200.sh"
  echo -e '#!/usr/bin/env bash\n\nxrandr -s 1920x1080' >> "/home/$name/Desktop/Change-Screen-Resolution/Change-to-1920x1080.sh"
  echo -e '#!/usr/bin/env bash\n\nxrandr -s 1920x1200' >> "/home/$name/Desktop/Change-Screen-Resolution/Change-to-1920x1200.sh"
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
  vnc_package=$(get_vnc_version $1 $2)
  safe_download ${output} "tiger_vnc.tar.gz" ${TIGERVNC_LINK}${vnc_package}
  tar -zxf tiger_vnc.tar.gz --strip 1 -C /  &> $output
  rm -f tiger_vnc.tar.gz

  if [[ -f /usr/libexec/vncserver && ! -f /usr/bin/vncserver ]] ; then
    ln -s /usr/libexec/vncserver /usr/bin/vncserver
  fi
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
  echo -e '#!/usr/bin/env bash\n\nopenbox-session &' > "/home/$name/.vnc/xstartup"
  chmod +x /home/$name/.vnc/xstartup
  sed -i "s/$vncPort = 5900/$vncPort = $port - 1/g" /usr/bin/vncserver
  if [[ ${operating_system} == "centos" ]]; then
    echo "VNCSERVERS=\"1:$name\"" >> /etc/sysconfig/vncservers
    echo "VNCSERVERARGS[1]=\"-geometry 1024x786\"" >> /etc/sysconfig/vncservers
    firewall-cmd --zone=public --add-port=$port/tcp --permanent &> $output
    firewall-cmd --reload &> $output
  fi
  setup_vnc_initd_service $output $name $operating_system
  service vncserver start &> $output
}

# Function to download a file using curl or wget depending on what is installed. This ensures better reliability across
# different platforms, as some OSs come with curl while others come with wget
# @param $1 - String where command output will be sent
# @param $2 - Name to save the downloaded file under
# @param $3 - URL to download the file from
# @return - None
function safe_download {
  output=$1
  output_filename=$2
  url=$3

  if [[ -x "$(which wget)" ]] ; then
    wget --no-check-cert -O ${output_filename} ${url} &> ${output}
  elif [[ -x "$(which curl)" ]] ; then
    curl -kLo ${output_filename} ${url} &> ${output}
  fi
}
