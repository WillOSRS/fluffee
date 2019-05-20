#!/bin/bash
clear
echo "Welcome to Fluffee's TRiBot Server Setup Script"
echo -n "Loading..."
while getopts ":v" OPTIONS ; do
  case ${OPTIONS} in
    v|-verbose)
      verbose=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Determines the operating system running on the server
# @return name of the operating system. Either Ubuntu, CentOS or Debian
function determine_os_name() {
  if [ -f /etc/redhat-release ]; then
    distro=$(cat /etc/redhat-release | sed s/\release.*// | sed s/Linux//g)
    elif [ -f /etc/os-release ]; then
    distro=$(sed -n '/\bNAME\b/p' /etc/os-release | sed s/NAME=//g | sed s/\"//g | sed 's,/,,g' | sed s/GNULinux//g)
  else
    distro=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
  fi
  echo -e ${distro} | tr -d '[:space:]'
}

# Determines the version of the operating system running on the server
# @return the version of the operating system.
function determine_os_version() {
  if [ -f /etc/redhat-release ]; then
    version=$(cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//)
  elif [ -f /etc/os-release ]; then
    version=$(sed -n '/\bVERSION_ID\b/p' /etc/os-release | sed s/VERSION_ID=//g | sed s/\"//g)
  else
    version=$(lsb_release -r -s)
  fi
  # If there's a decimal point, we want to remove it and everything after it.
  # i.e. truncate 9.12.3 to 9
  echo ${version} | sed -e 's/\..*//g'
}

# Gets the download link for the install script
# @param $1 - String containing the name of the operating system currently running
# @return String containing the download link of the install script
function get_download_link() {
  distro=$1
  if [ "$distro"  = "Ubuntu" ]; then
    echo "https://bitbucket.org/teamfluffee/fluffees-server-setup/raw/add-shared-functions/ubuntu/ubuntu-install.sh"
  elif [ "$distro" = "Debian" ]; then
    echo "https://bitbucket.org/teamfluffee/fluffees-server-setup/raw/add-shared-functions/debian/debian-install.sh"
  elif [ "$distro" = "CentOS" ]; then
    echo "https://bitbucket.org/teamfluffee/fluffees-server-setup/raw/add-shared-functions/centos/centos-install.sh"
  else
    echo "Unsupported OS"
  fi
}

# Gets the bit type of the operating system via parsed uname -m
# @return String containing either 32 or 64, representing the bit type of the OS
function get_bit_type() {
  uname=$(uname -m)
  if [ "$uname" = "x86_64" ] ; then
    echo "64"
  else
    echo "32"
  fi
}

# Gets the desired VNC port for the server by prompting the user for the port
# @return String containing the desired VNC port for the server
function get_vnc_port() {
  read -p "Desired VNC port must be greater than 1024: " vncport
  while(( vncport < 1025 )); do
    read -p "Please enter a port greater than 1024: " vncport
  done
  echo ${vncport}
}

# Gets the desired SSH port for the server by prompting the user for the port
# @param $1 - The VNC port, passed to ensure the VNC port and SSH port don't conflict
# @return String containing the desired SSH port for the server
function get_ssh_port() {
  vncport=$1
  read -p "Desired SSH port must be greater than 1024, and different from VNC port: " sshport
  while(( sshport < 1025 || sshport == vncport )); do
    read -p "Please enter a port that is greater than 1024 and different from VNC port: " sshport
  done
  echo ${sshport}
}

# Gets the desired username for the server by prompting the user for the account name.
# Does checks to ensure the username is in all lowercase letters, as Linux/Unix does not allow capitals in accounts
# @return String containing the desired username
function get_username() {
  read -p "Desired user account name, must be all lowercase letters: " name
  remainder=$(tr -d a-z <<<$name)
  while [ ! -z $remainder ];do
    read -p "Invalid value entered. Please try again. Must be all lowercase letters: " name
    remainder=$(tr -d a-z <<<$name)
  done
  echo ${name}
}

os=$(determine_os_name)
os_version=$(determine_os_version)
bit_type=$(get_bit_type)
link=$(get_download_link $os)

echo " -------------------- Fluffee's TRiBot Server Setup Script -------------------- "
echo "${os} ${os_version}, ${bit_type} bit has been autodetected"
username=$(get_username)
vnc_port=$(get_vnc_port)
read -p "Please enter your desired VNC password: " vnc_password
ssh_port=$(get_ssh_port $vnc_port)
read -p "Please enter your desired SSH password: " ssh_password

wget -O install.sh --no-check-cert ${link}
bash install.sh ${verbose} ${username} ${ssh_password} ${vnc_password} ${vnc_port} ${ssh_port} ${bit_type} ${os_version}
rm install.sh


echo " -------------------- Fluffee's TRiBot Server Setup Script -------------------- "
echo "Operating System: $os"
echo "SSH Username:     $username"
echo "SSH Password:     $ssh_password"
echo "VNC Password:     $vnc_password"
echo "SSH Port:         $ssh_port"
echo "VNC Port:         $vnc_port"
echo ""
echo "You can now connect to your server via VNC"
echo "Root logins are disabled, and the new SSH port must be used after this session"
echo "You must also SSH in with the new SSH username and password"
echo "Please see the thread or message me on TRiBot for more help :)"
