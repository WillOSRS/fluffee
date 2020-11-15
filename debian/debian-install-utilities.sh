# Runs an initial package update, then installs all base required packages
# @param $1 - boolean flag to indicate whether or not to run the function in verbose mode
# @param $2 - Number indicating the bit type of the system, either 32 or 64
# @param $3 - Number indicating the Debian version, either 7, 8 or 9
# @return - None
function initial_setup() {
  output=$(determine_output $1)
  bit_type=$2
  debian_version=$3
  apt_name="apt"
  font_version="libxfont1"

  if [[ "${debian_version}" -lt 9 ]] ; then
    apt_name="apt-get"

    sed -i -e 's/\(ftp\.\).*\(debian\.org\)/archive\.\2/g' /etc/apt/sources.list
    sed -i '/wheezy-updates\|jessie-updates\|security\|cdrom\|^$\|^# \+$/d' /etc/apt/sources.list

    if [[ "${debian_version}" -eq 8 ]] ; then
      mkdir /dev/fuse
      chmod 777 /dev/fuse
      ${apt_name} -y install fuse
    fi
  elif  [[ "${debian_version}" -ge 10 ]] ; then
    font_version="libxfont2"
  fi

  ${apt_name} update &> ${output}
  ${apt_name} install -y xinit sudo locales debconf-utils wget nano libxslt1.1  bzip2 tar xauth x11-xkb-utils xkb-data ${font_version} x11-xserver-utils &> ${output}
  ${apt_name} install -y gtk2-engines openbox pcmanfm gnome-icon-theme fbpanel lxtask xterm curl &> ${output}

  safe_download ${output} "keyboard-settings.txt" https://bitbucket.org/teamfluffee/fluffees-server-setup/raw/master/shared/keyboard-settings.txt
  debconf-set-selections < keyboard-settings.txt &> ${output}
  ${apt_name} install -y keyboard-configuration &> ${output}

  dpkg-reconfigure keyboard-configuration -f noninteractive &> ${output}

  export LANG=en_US.UTF-8
  export LANGUAGE=en_US.UTF-8
  sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
  echo 'LANG="en_US.UTF-8"'>/etc/default/locale
  dpkg-reconfigure --frontend=noninteractive locales &> ${output}
  update-locale LANG=en_US.UTF-8 &> ${output}
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
  sed -ie 's/\(.*\)PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
  echo -e "\nAllowUsers $name root" >> /etc/ssh/sshd_config
  service ssh restart &> $output
}

# Creates new user account using provided username and password. Gives user sudo permissions
# @param $1 - boolean flag to indicate whether or not to run the function in verbose mode
# @param $2 - Name of the user to create (in all lowercase)
# @param $3 - Password of the user to create
# @return - None
function create_user() {
  output=$(determine_output $1) 
  name=$2
  password=$3
  
  adduser $name --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password &> $output
  echo "$name:$password" | chpasswd
  adduser $name sudo &> $output
  groupadd netdev &> $output
  adduser $name netdev &> $output
}

# Runs some cleanup work on Debian to remove any services we don't need, to reduce bloat
# @param $1 - boolean flag to indicate whether or not to run the function in verbose mode
# @return - None
function cleanup() {
  output=$(determine_output $1) 

  apt-get remove -y clipit gvfs* lxmusic mpv pulseaudio pavucontrol evince wicd light-locker at-spi2-core &> $output
  apt-get autoremove -y &> $output
  rm -f /etc/xdg/autostart/clipit-startup.desktop &> $output
  rm -f /etc/xdg/autostart/pulseaudio.desktop &> $output
  rm -f /etc/xdg/autostart/wicd-tray.desktop &> $output
  rm -f /etc/xdg/autostart/light-locker.desktop &> $output
  rm -f /etc/xdg/autostart/at-spi-dbus-bus.desktop &> $output
  sudo systemctl -q mask sleep.target suspend.target hibernate.target hybrid-sleep.target
}

# Downloads and sets up Java 8 from the Oracle site.
# This includes instaling Java, and ensuring .jar double clicking works
# @param $1 - boolean flag to indicate whether or not to run the function in verbose mode
# @param $2 - Bit type of the operating system as int, 32 or 64
# @return - None
function install_java() {
  output=$(determine_output $1) 
  
  jdk_download=$(get_jdk_download_link $output $2 tar.gz) &> $output
  safe_download ${output} "jdk_install.tar.gz" ${jdk_download}

  mkdir -p /usr/lib/jvm/java-8-oracle/ &> $output
  tar -xzf jdk_install.tar.gz -C /usr/lib/jvm/java-8-oracle/ --strip-components=1 &> $output

  update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-8-oracle/bin/java 100 &> $output
  update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-8-oracle/bin/javac 100 &> $output

  rm /usr/lib/jvm/java-8-oracle/jre/bin/java

  ln -s /usr/lib/jvm/java-8-oracle/bin/java /usr/lib/jvm/java-8-oracle/jre/bin/java
  rm -f jdk_install.tar.gz &> $output
}

# Downloads and installs the latest Firefox-ESR from the Mozilla Site
# @param $1 - boolean flag to indicate whether or not to run the function in verbose mode
# @param $2 - Bit type of the operating system as int, 32 or 64
# @return - None
function install_firefox() {
  output=$(determine_output $1) 
  if [[ $2 -eq 64 ]] ; then
    bit_type=64
    java_extension=amd64
  else
    bit_type=
    java_extension=i386
  fi
  
  safe_download ${output} "firefox.tar.bz2" "https://download.mozilla.org/?product=firefox-esr-latest&os=linux${bit_type}&lang=en-US"
  mkdir -p /usr/local/firefox
  tar xvjf firefox.tar.bz2 -C /usr/local/ &> $output
  ln -s /usr/local/firefox/firefox /usr/bin/firefox

  mkdir -p /usr/lib/mozilla/plugins
  update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/local/firefox/firefox 100 &> $output
  update-alternatives --install /usr/lib/mozilla/plugins/libjavaplugin.so mozilla-javaplugin.so /usr/lib/jvm/java-8-oracle/jre/lib/${java_extension}/libnpjp2.so 1000 &> $output
  update-alternatives --set "mozilla-javaplugin.so" "/usr/lib/jvm/java-8-oracle/jre/lib/${java_extension}/libnpjp2.so" &> $output
}
