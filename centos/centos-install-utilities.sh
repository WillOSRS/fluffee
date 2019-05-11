#!/bin/bash

TIGERVNC_LINK="https://dl.bintray.com/tigervnc/stable/"

# @param $1 - String where command output will be sent
# @param $2 - Number indicating the bit type to download, either 32 or 64
# @return String containing the download link for the nux repo
function get_nox_download_link() {
  output=$1

  if [[ $2 == 32 ]] ; then
    bit_type="i386"
  else
    bit_type="x86_64"
  fi

  echo "http://li.nux.ro/download/nux/dextop/el6/${bit_type}/nux-dextop-release-0-2.el6.nux.noarch.rpm"
}

# Parses the fedora download site to determine the latest version
# @param $1 - String where command output will be sent
# @param $2 - The base fedora download site to parse from
# @return Number indicating the latest fedora release
function get_fedora_version() {
  output=$1
  fedora_base=$2

  wget -O package-temp.txt ${fedora_base} &> ${output}
  sed -i '/\[DIR\]/!d' package-temp.txt
  sed -i "s/.*href=\"\(.*\)\/\">.*/\1/" package-temp.txt
  echo $(cat package-temp.txt | sort -n | tail -1 && rm -f package-temp.txt)
}

# Gets the lxtask rpm download link from the fedora packages host
# @param $1 - String where command output will be sent
# @param $2 - Number indicating the bit type to download, either 32 or 64
# @param $3 - Package name to get link for
# @return The download link of the lxtask rpm from the fedora site
function get_fedora_download_link() {
  output=$1
  package_name=$3
  package_letter=$(echo $package_name | head -c 1)
  if [ $2 == 32 ] ; then
    fedora_base="https://dl.fedoraproject.org/pub/fedora-secondary/releases/"
    bit_type="i386"
  else
    fedora_base="https://dl.fedoraproject.org/pub/fedora/linux/releases/"
    bit_type="x86_64"
  fi

  packages_page=${fedora_base}
  packages_page+=$(get_fedora_version ${output} ${fedora_base})
  packages_page+="/Everything/${bit_type}/os/Packages/${package_letter}/"
  wget -O package-temp.txt ${packages_page} &> ${output}
  sed -i '/'"${package_name}"'/!d' package-temp.txt
  sed -i "s/.*href=\"\(.*\)\">.*/\1/" package-temp.txt
  echo ${packages_page}$(cat package-temp.txt && rm -f package-temp.txt)
}

# Installs lxtask by downloading from the Fedora repo
# @param $1 - Boolean flag indicating verbostiy of the procedure
# @param $2 - Number indicating the bit type to download, either 32 or 64
# @return None
function install_lxtask() {
  output=$(determine_output $1)
  bit_type=$2

  download_link=$(get_fedora_download_link ${output} ${bit_type} lxtask)
  wget -O lxtask.rpm ${download_link} &> ${output}
  yum -y localinstall lxtask.rpm
  rm -f lxtask.rpm
}

# Installs lxtask by downloading from the Fedora repo
# @param $1 - Boolean flag indicating verbostiy of the procedure
# @param $2 - Number indicating the bit type to download, either 32 or 64
# @param $3 - Number indicating the centos version, either 6 or 7
# @return None
function install_fbpanel() {
  output=$(determine_output $1)
  bit_type=$2
  centos_version=$3
  
  if [[ ${centos_version} = 7 ]] ; then
    download_link=$(get_fedora_download_link ${output} ${bit_type} fbpanel)
    wget -O fbpanel.rpm ${download_link} &> ${output}
    yum -y install fbpanel.rpm
    rm -f fbpanell.rpm
  else
    yum -y install fbpanel
  fi
}

# Installs all files in a directory, and then removes the directory
# @param $1 - String where command output will be sent
# @param $2 - Path where the files to install lie
# @return None
function install_all() {
  output=$1
  path=$2

  for filename in ${path}; do
    yum -y --nogpgcheck install ${filename} &> $output
  done
  rm -f ${path}
}

# Runs an initial package update, then installs all base required packages
# @param $1 - boolean flag to indicate whether or not to run the function in verbose mode
# @param $2 - Number indicating the bit type of the system, either 32 or 64
# @param $3 - Number indicating the CentOS version, either 6 or 7
# @return - None
function initial_setup() {
  output=$(determine_output $1)
  bit_type=$2
  centos_version=$3

  yum -y update --downloaddir=/root/updates --downloadonly &> $output
  install_all ${output} '/root/updates/*.rpm'
  yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-${3}.noarch.rpm &> $output
  yum -y install $(get_nox_download_link $output $bit_type) &> $output
  yum -y update --downloaddir=/root/updates --downloadonly &> $output
  install_all ${output} '/root/updates/*.rpm'
  yum -y history sync &> $output
  yum -y install --downloaddir=/root/updates --downloadonly perl sudo wget bzip2 xterm xorg-x11-drivers xorg-x11-xinit xorg-x11-xauth &> $output
  install_all ${output} '/root/updates/*.rpm'
  yum -y groupinstall --downloaddir=/root/updates --downloadonly fonts
  install_all ${output} '/root/updates/*.rpm'
  yum -y install --downloaddir=/root/updates --downloadonly gtk2-engines firefox openbox pcmanfm gnome-icon-theme.noarch &> ${output}
  install_all ${output} '/root/updates/*.rpm'
  rm -rf /root/updates/
}

# Sets the SSH port, blocks root login and allows the new user
# @param $1 - boolean flag to indicate whether or not to run the function in verbose mode
# @param $2 - Name of user to allow to access SSH
# @param $3 - Port number to permit SSH on
# @return - None
function setup_ssh() {
  output=$(determine_output $1) 
  name=$2
  port=$3

  sed -i "s/#Port 22/Port $port/g" /etc/ssh/sshd_config
  sed -i "s/#PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
  echo -e "\nAllowUsers $name root" >> /etc/ssh/sshd_config
  firewall-cmd --zone=public --add-port=$port/tcp --permanent &> $output
  firewall-cmd --reload &> $output
  service sshd restart &> $output
}

function create_user() {
  output=$(determine_output $1) 
  name=$2
  password=$3
  
  adduser $name &> $output
  echo "$name:$password" | chpasswd
  usermod -aG wheel $name &> $output
  sed -i "s/# %wheel/%wheel/g" /etc/sudoers
}

# Downloads and sets up Java 8 from the Oracle site.
# This includes instaling Java, and ensuring .jar double clicking works
# @param $1 - boolean flag to indicate whether or not to run the function in verbose mode
# @param $2 - Bit type of the operating system as int, 32 or 64
# @return - None
function install_java() {
  output=$(determine_output $1) 
  
  jdk_download=$(get_jdk_download_link $output $2 rpm)
  wget -O jdk_install.rpm --header "Cookie: oraclelicense=accept-securebackup-cookie" --no-check-cert ${jdk_download}
  yum -y localinstall jdk_install.rpm
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
  chmod 777 /home/$name/Desktop/Bots #TODO: Just give run permissions to all .jars
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

# Sets up tiger vnc for practical use
# @param $1 - boolean flag to indicate whether or not to run the function in verbose mode
# @param $2 - Port number to run the vnc server on
# @param $3 - Name of user to run VNC under
# @param $4 - Password string to use for logging in to VNC
# @return - None
function setup_vnc() {
  output=$(determine_output $1)
  port=$2
  name=$3
  password=$4

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
  firewall-cmd --zone=public --add-port=$port/tcp --permanent &> $output
  firewall-cmd --reload &> $output
  setup_vnc_initd_service $output $name
  service vncserver start &> $output
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
  mkdir -p /home/$name/.local/share/applications &> $output
  echo "[Added Associations]" >> /home/$name/.local/share/applications/mimeapps.list
  echo "application/x-java-archive=JB-java-jdk8.desktop;" >> /home/$name/.local/share/applications/mimeapps.list
}

source shared-utilities.sh

