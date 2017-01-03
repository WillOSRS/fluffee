#!/bin/bash
clear
echo "Welcome to Fluffee's Server Setup Script"
UNAME=$(uname -m)
if [ -f /etc/redhat-release ]; then
    DISTRO=$(cat /etc/redhat-release | sed s/\release.*//)
    VERSION=$(cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//)
else
    DISTRO=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
    VERSION=$(lsb_release -r -s)
fi
DISTRO="$(echo -e "${DISTRO}" | tr -d '[:space:]')"
if [ "$UNAME" = "x86_64" ]; then
    if [ "$DISTRO" = "Ubuntu" ]; then
        OS="Ubuntu $VERSION x64"
		if [ $(bc <<< "$VERSION > 12") -eq 1 -a $(bc <<< "$VERSION <= 13") -eq 1 ]; then
		    LINK="https://raw.githubusercontent.com/iFluffee/Fluffees-Server-Setup/master/Ubuntu/Ubuntu-12.04.5-64-Bit-Setup.sh"
			FILE=Ubuntu-12.04.5-64-Bit-Setup.sh
		elif [ $(bc <<< "$VERSION > 14") -eq 1 -a $(bc <<< "$VERSION <= 15") -eq 1 ]; then
		    LINK="https://raw.githubusercontent.com/iFluffee/Fluffees-Server-Setup/master/Ubuntu/Ubuntu-14.04.5-64-Bit-Setup.sh"
			FILE=Ubuntu-14.04.5-64-Bit-Setup.sh
		elif [ $(bc <<< "$VERSION > 16") -eq 1 -a $(bc <<< "$VERSION <= 17") -eq 1 ]; then
		    LINK="https://raw.githubusercontent.com/iFluffee/Fluffees-Server-Setup/master/Ubuntu/Ubuntu-16.04.5-64-Bit-Setup.sh"
			FILE=Ubuntu-16.04.5-64-Bit-Setup.sh
		fi
    elif [ "$DISTRO" = "Debian" ]; then
        OS="Debian $VERSION x64"
		if [ $(bc <<< "$VERSION > 7") -eq 1 -a $(bc <<< "$VERSION <= 8") -eq 1 ]; then
		    LINK="https://raw.githubusercontent.com/iFluffee/Fluffees-Server-Setup/master/Debian/Debian-7/Debian-7-64-Bit-Setup.sh"
			FILE=Debian-7-64-Bit-Setup.sh
		elif [ $(bc <<< "$VERSION > 8") -eq 1 -a $(bc <<< "$VERSION <= 9") -eq 1 ]; then
		    LINK="https://raw.githubusercontent.com/iFluffee/Fluffees-Server-Setup/master/Debian/Debian-8/Debian-8-64-Bit-Setup.sh"
			FILE=Debian-8-64-Bit-Setup.sh
		fi
    elif [ "$DISTRO" = "CentOS" ]; then
        OS="CentOS $VERSION x64"
		if [ $(bc <<< "$VERSION > 6") -eq 1 -a $(bc <<< "$VERSION <= 7") -eq 1 ]; then
		    LINK="https://raw.githubusercontent.com/iFluffee/Fluffees-Server-Setup/master/CentOS/CentOS-6.8-64-Bit-Setup.sh"
			FILE=CentOS-6.8-64-Bit-Setup.sh
		elif [ $(bc <<< "$VERSION > 7") -eq 1 -a $(bc <<< "$VERSION <= 8") -eq 1 ]; then
		    LINK="https://raw.githubusercontent.com/iFluffee/Fluffees-Server-Setup/master/CentOS/CentOS-7.2-64-Bit-Setup.sh"
			FILE=CentOS-7.2-64-Bit-Setup.sh
		fi
	else
		OS = "Unsupported OS"
    fi
else
   if [ "$DISTRO" = "Ubuntu" ]; then
        OS="Ubuntu $VERSION x86"
		if [ $(bc <<< "$VERSION > 12") -eq 1 -a $(bc <<< "$VERSION <= 13") -eq 1 ]; then
		    LINK="https://raw.githubusercontent.com/iFluffee/Fluffees-Server-Setup/master/Ubuntu/Ubuntu-12.04.5-32-Bit-Setup.sh"
			FILE=Ubuntu-12.04.5-32-Bit-Setup.sh
		elif [ $(bc <<< "$VERSION > 14") -eq 1 -a $(bc <<< "$VERSION <= 15") -eq 1 ]; then
		    LINK="https://raw.githubusercontent.com/iFluffee/Fluffees-Server-Setup/master/Ubuntu/Ubuntu-14.04.5-32-Bit-Setup.sh"
			FILE=Ubuntu-14.04.5-32-Bit-Setup.sh
		elif [ $(bc <<< "$VERSION > 16") -eq 1 -a $(bc <<< "$VERSION <= 17") -eq 1 ]; then
		    LINK="https://raw.githubusercontent.com/iFluffee/Fluffees-Server-Setup/master/Ubuntu/Ubuntu-16.04.5-32-Bit-Setup.sh"
			FILE=Ubuntu-16.04.5-32-Bit-Setup.sh
		fi
    elif [ "$DISTRO" = "Debian" ]; then
        OS="Debian $VERSION x86"
		if [ $(bc <<< "$VERSION > 7") -eq 1 -a $(bc <<< "$VERSION <= 8") -eq 1 ]; then
		    LINK="https://raw.githubusercontent.com/iFluffee/Fluffees-Server-Setup/master/Debian/Debian-7/Debian-7-32-Bit-Setup.sh"
			FILE=Debian-7-32-Bit-Setup.sh
		elif [ $(bc <<< "$VERSION > 8") -eq 1 -a $(bc <<< "$VERSION <= 9") -eq 1 ]; then
		    LINK="https://raw.githubusercontent.com/iFluffee/Fluffees-Server-Setup/master/Debian/Debian-8/Debian-8-32-Bit-Setup.sh"
			FILE=Debian-8-32-Bit-Setup.sh
		fi
    elif [ "$DISTRO" = "CentOS" ]; then
        OS="CentOS $VERSION x86"
		if [ $(bc <<< "$VERSION > 6") -eq 1 -a $(bc <<< "$VERSION <= 7") -eq 1 ]; then
		    LINK="https://raw.githubusercontent.com/iFluffee/Fluffees-Server-Setup/master/CentOS/CentOS-6.8-32-Bit-Setup.sh"
			FILE=CentOS-6.8-32-Bit-Setup.sh
		elif [ $(bc <<< "$VERSION > 7") -eq 1 -a $(bc <<< "$VERSION <= 8") -eq 1 ]; then
		    LINK="https://raw.githubusercontent.com/iFluffee/Fluffees-Server-Setup/master/CentOS/CentOS-7.2-32-Bit-Setup.sh"
			FILE=CentOS-7.2-32-Bit-Setup.sh
		fi
	else
		OS = "Unsupported OS"
    fi
fi

echo "Fluffee's VPS Setup Script 2.0, has auto detected $OS"
read -p "Desired VNC port must be greater than 1000: " vncport

while(( vncport < 1000 )); do
    read -p "Please enter a port greater than 1000: " vncport
done

read -p "Desired SSH port must be greater than 1000, and different from VNC port: " sshport
while(( sshport < 1000 || sshport == vncport )); do
    read -p "Please enter a port that is greater than 1000 and different from VNC port: " sshport
done

read -p "Desired user account name, must be all lowercase letters: " name
remainder=$(tr -d a-z <<<$name)
while [ ! -z $remainder ];do
    read -p "Invalid value entered. Please try again. Must be all lowercase letters: " name
    remainder=$(tr -d a-z <<<$name)
done
read -p "Desired SSH password: " sshpassword
read -p "Desired VNC password: " vncpassword

echo "Running OS specific install script"
wget $LINK &> /dev/null
chmod +x $FILE
clear
./$FILE $name $sshport $vncport $sshpassword $vncpassword
rm -f 'tightvnc-1.3.10_unixsrc.tar.gz'
rm -rf 'vnc_unixsrc'
rm -f 'Ubuntu-16.04.5-32-Bit-Setup.sh'