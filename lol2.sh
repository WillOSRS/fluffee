#!/bin/bash

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
		if [ $(bc <<< "$VERSION > 7") -eq 1 -a $(bc <<< "$VERSION <= 8") -eq 1 ]; then
		    LINK="INSERT LINK"
		fi
    elif [ "$DISTRO" = "Debian" ]; then
        OS="Debian $VERSION x64"
		if [ $(bc <<< "$VERSION > 7") -eq 1 -a $(bc <<< "$VERSION <= 8") -eq 1 ]; then
		    LINK="INSERT LINK"
		elif [ $(bc <<< "$VERSION > 8") -eq 1 -a $(bc <<< "$VERSION <= 9") -eq 1 ]; then
		    LINK="INSERT LINK"
		fi
    elif [ "$DISTRO" = "CentOS" ]; then
        OS="CentOS $VERSION x64"
		if [ $(bc <<< "$VERSION > 7") -eq 1 -a $(bc <<< "$VERSION <= 8") -eq 1 ]; then
		    LINK="INSERT LINK"
		fi
	else
		OS = "Unsupported OS"
    fi
else
   if [ "$DISTRO" = "Ubuntu" ]; then
        OS="Ubuntu $VERSION x86"
		if [ $(bc <<< "$VERSION > 7") -eq 1 -a $(bc <<< "$VERSION <= 8") -eq 1 ]; then
		    LINK="INSERT LINK"
		fi
    elif [ "$DISTRO" = "Debian" ]; then
        OS="Debian $VERSION x86"
		if [ $(bc <<< "$VERSION > 7") -eq 1 -a $(bc <<< "$VERSION <= 8") -eq 1 ]; then
		    LINK="INSERT LINK"
		elif [ $(bc <<< "$VERSION > 8") -eq 1 -a $(bc <<< "$VERSION <= 9") -eq 1 ]; then
			LINK="INSERT LINK"
		fi
    elif [ "$DISTRO" = "CentOS" ]; then
        OS="CentOS $VERSION x86"
		if [ $(bc <<< "$VERSION > 7") -eq 1 -a $(bc <<< "$VERSION <= 8") -eq 1 ]; then
		    LINK="INSERT LINK"
		fi
	else
		OS = "Unsupported OS"
    fi
fi

echo "Fluffee's VPS Setup Script 2.0, has auto detected $OS"

if (( vncport > 1000 )); then
    echo expression evaluated as true
else
    temp=$(uname -m)
    echo expression evaluated as false $vncport $temp
fi

REPLY=7.11
if [ $(bc <<< "$VERSION > 7") -eq 1 -a $(bc <<< "$VERSION <= 8") -eq 1 ]; then
  L
fi