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
  echo $(cat tiger.txt | tail -1)
}

# Creates the tiger vnc init.d service
# @param $1 - boolean flag indicating verbosity of function
# @param $2 - Name of the user to run the VNC under
# @return None
function setup_vnc_initd_service() {
  output=$(determine_output $1)
  name=$2

  wget -O /etc/init.d/vncserver link &> $output
  chmod +x /etc/init.d/vncserver
  sed -i "s/user_name/${name}/g" /etc/init.d/vncserver
}

# Creates the tiger vnc systemd service
# @param $1 - boolean flag indicating verbosity of function
# @param $2 - Name of the user to run the VNC under
# @return None
function setup_vnc_systemd_service() {
  echo ""
}

# Parses the oracle page to find the link to the JDK 8 downloads
# @param $1 - boolean flag to indicate whether or not to run the function in verbose mode
# @return Extension to the base oracle link where the JDK 8 downloads are found
function get_jdk_downloads_page() {
  output=$(determine_output $1)
  wget -O java_downloads.txt ${BASE_JAVA}${JAVA_DOWNLOAD_PAGE} &> $output
  sed -i "/.*jdk8-downloads.*/!d" java_downloads.txt
  sed -i "s/.*href=\"\(.*\)\"><img.*/\1/" java_downloads.txt
  echo $(cat java_downloads.txt | tail -1)
}

# Parses the JDK downloads page to find the download link
# @param $1 - boolean flag to indicate whether or not to run the function in verbose mode
# @param $2 - Bit type of the operating system as int, 32 or 64
# @param $3 - File extension (rpm or tar.gz)
# @return The download link for the JDK
function get_jdk_download_link() {
  bit_type =$2
  file_extension=$3

  wget -O java_downloads.txt ${BASE_JAVA}$(get_jdk_downloads_page $1)
  sed -i '/oth-JPR/!d' java_downloads.txt
  sed -i '/demos-oth-JPR/d' java_downloads.txt
  sed -i '/linux-i\|linux-x/!d' java_downloads.txt
  sed -i '/${bit_type}/!d' java_downloads.txt
  sed -i '/${file_extension}/!d' java_downloads.txt
  echo "$(tail -1 java_downloads.txt)" > java_downloads.txt
  sed -i "s/.*filepath\":\"\(.*\)\",\"MD5\":.*/\1/" java_downloads.txt
  echo $(cat java_downloads.txt)
}

# Sets up the openbox desktop environment
# @param $1 - boolean flag indicating verbosity of function
# @param $2 - Name of the user to run the VNC under
# @return None
function setup_desktop_environment() {
  output=$(determine_output $1)
  name=$2

  #TODO: Just create the files and wget them

  update-alternatives --install /usr/bin/x-file-manager x-file-manager /usr/bin/pcmanfm 100 &> $output
  update-alternatives --install /usr/bin/x-terminal x-terminal /usr/bin/xterm 100 &> $output
  mkdir -p /home/$name/.config/openbox &> $output
  echo "fbpanel &" >> /home/$name/.config/openbox/autostart
  echo "pcmanfm --desktop &" >> /home/$name/.config/openbox/autostart
  mkdir -p /home/$name/.config/fbpanel &> $output
  cp /usr/share/fbpanel/default /home/$name/.config/fbpanel/ &> $output
  sed -i "s/type = volume//g" /home/$name/.config/fbpanel/default &> $output
  sed -i "s/width = 86/width = 100/g" /home/$name/.config/fbpanel/default &> $output
  sed -i "s/roundcorners = true/roundcorners = false/g" /home/$name/.config/fbpanel/default &> $output
  sed -i "s/icon = file-manager/image = \/usr\/share\/icons\/nuoveXT2\/32x32\/apps\/file-manager.png/g" /home/$name/.config/fbpanel/default &&> $output
  sed -i "s/icon = terminal/image = \/usr\/share\/icons\/nuoveXT2\/32x32\/apps\/terminal.png/g" /home/$name/.config/fbpanel/default &> $output
  sed -i "s/icon = web-browser/image = \/usr\/share\/icons\/nuoveXT2\/32x32\/apps\/web-browser.png/g" /home/$name/.config/fbpanel/default &> $output
  mkdir -p /home/$name/.config/pcmanfm/default
  echo '[*]' >> /home/$name/.config/pcmanfm/default/desktop-items-0.conf
  echo 'wallpaper_mode=crop' >> /home/$name/.config/pcmanfm/default/desktop-items-0.conf
  echo 'wallpaper_common=1' >> /home/$name/.config/pcmanfm/default/desktop-items-0.conf
  echo 'desktop_bg=#000000' >> /home/$name/.config/pcmanfm/default/desktop-items-0.conf
  echo 'desktop_fg=#ffffff' >> /home/$name/.config/pcmanfm/default/desktop-items-0.conf
  echo 'desktop_shadow=#000000' >> /home/$name/.config/pcmanfm/default/desktop-items-0.conf
  echo 'desktop_font=Sans 12' >> /home/$name/.config/pcmanfm/default/desktop-items-0.conf
  echo 'show_wm_menu=0' >> /home/$name/.config/pcmanfm/default/desktop-items-0.conf
  echo 'sort=mtime;ascending;' >> /home/$name/.config/pcmanfm/default/desktop-items-0.conf
  echo 'show_documents=0' >> /home/$name/.config/pcmanfm/default/desktop-items-0.conf
  echo 'show_trash=1' >> /home/$name/.config/pcmanfm/default/desktop-items-0.conf
  echo 'show_mounts=0' >> /home/$name/.config/pcmanfm/default/desktop-items-0.conf
}
