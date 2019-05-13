# Runs an initial package update, then installs all base required packages
# @param $1 - boolean flag to indicate whether or not to run the function in verbose mode
# @param $2 - Number indicating the bit type of the system, either 32 or 64
# @param $3 - Number indicating the CentOS version, either 6 or 7
# @return - None
function initial_setup() {
  output=$(determine_output $1)
  bit_type=$2
  centos_version=$3

  apt-get update --downloaddir=/root/updates --downloadonly &> $output
  install_all ${output} '/root/updates/*.deb'
  yum -y install --downloaddir=/root/updates --downloadonly sudo wget nano libxslt1.1  bzip2 tar &> $output
  install_all ${output} '/root/updates/*.deb'
  yum -y install --downloaddir=/root/updates --downloadonly gtk2-engines firefox openbox pcmanfm gnome-icon-theme fbpanel lxtask xterm &> ${output}
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

  apt-get remove -y clipit gvfs* lxmusic mpv pulseaudio pavucontrol evince wicd light-locker at-spi2-core &> /dev/null
  apt-get autoremove -y &> /dev/null
  rm -f /etc/xdg/autostart/clipit-startup.desktop &> /dev/null
  rm -f /etc/xdg/autostart/pulseaudio.desktop &> /dev/null
  rm -f /etc/xdg/autostart/wicd-tray.desktop &> /dev/null
  rm -f /etc/xdg/autostart/light-locker.desktop &> /dev/null
  rm -f /etc/xdg/autostart/at-spi-dbus-bus.desktop &> /dev/null
  sudo systemctl -q mask sleep.target suspend.target hibernate.target hybrid-sleep.target
}
