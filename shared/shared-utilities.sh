#!/bin/bash

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
# @return None
function setup_vnc_initd_service() {
  output=$1
  name=$2

  wget -O /etc/init.d/vncserver https://bitbucket.org/Fluffee/fluffees-server-setup/raw/add-shared-functions/shared/tigervnc/vncserver-initd.service
  sed -i "s/user_name/$name/g" /etc/init.d/vncserver
  chmod +x /etc/init.d/vncserver
  echo "service vncserver start" >> /etc/rc.local
}

# Creates the tiger vnc systemd service
# @param $1 - boolean flag indicating verbosity of function
# @param $2 - Name of the user to run the VNC under
# @return None
function setup_vnc_systemd_service() {
  echo ""
}

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

  wget -O java_downloads.txt ${BASE_JAVA}$(get_jdk_downloads_page $1)
  sed -i '/oth-JPR/!d' java_downloads.txt
  sed -i '/demos-oth-JPR/d' java_downloads.txt
  sed -i '/linux-i\|linux-x/!d' java_downloads.txt
  sed -i '/'"${bit_type}"'/!d' java_downloads.txt
  sed -i '/'"${file_extension}"'/!d' java_downloads.txt
  echo "$(tail -1 java_downloads.txt)" > java_downloads.txt
  sed -i "s/.*filepath\":\"\(.*\)\",\"MD5\":.*/\1/" java_downloads.txt
  echo $(cat java_downloads.txt && rm -f java_downloads.txt)
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

  wget -O /home/$name/.config/openbox/autostart https://bitbucket.org/Fluffee/fluffees-server-setup/raw/add-shared-functions/shared/desktop/openbox-autostart.txt &> $output
  wget -O /home/$name/.config/fbpanel/default https://bitbucket.org/Fluffee/fluffees-server-setup/raw/add-shared-functions/shared/desktop/fbpanel-default-config.txt &> $output
  wget -O /home/$name/.config/pcmanfm/default/desktop-items-0.conf https://bitbucket.org/Fluffee/fluffees-server-setup/raw/add-shared-functions/shared/desktop/pcmanfm-desktop-items.txt &> $output
  wget -O /home/$name/.config/pcmanfm/default/pcmanfm.conf https://bitbucket.org/Fluffee/fluffees-server-setup/raw/add-shared-functions/shared/desktop/pcmanfm-default-config.txt &> $output
  wget -O /home/$name/.gtkrc-2.0 https://bitbucket.org/Fluffee/fluffees-server-setup/raw/add-shared-functions/shared/desktop/gtk-settings.txt &> $output
  sed -i "s/user_name/$name/g" /home/$name/.gtkrc-2.0
  chown -R ${name}:${name} /home/${name}/*
  chown -R ${name}:${name} /home/${name}/.*
  update-alternatives --install /usr/bin/x-file-manager x-file-manager /usr/bin/pcmanfm 100 &> $output
  update-alternatives --install /usr/bin/x-terminal x-terminal /usr/bin/xterm 100 &> $output
  update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/firefox 100 &> $output
  dbus-uuidgen > /var/lib/dbus/machine-id
}
