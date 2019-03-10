#!/bin/bash

# Script to automate the install of a desktop environment and TRiBot on CentOS
# @param $1 - Boolean flag to indicate verbosity of script
# @param $2 - User name of account to create, as String
# @param $3 - Password of the account to create
# @param $4 - Password to be used for VNC access
# @param $5 - Port to use for VNC connections
# @param $6 - Port to use for SSH connections, as int
# @param $7 - Bit type of the OS, either 32 or 64
# @param $8 - Version of CentOS running, either 6, 7 or 8
# @return None

verbose=$1
user_name=$2
account_password=$3
vnc_password=$4
vnc_port=$5
ssh_port=$6
bit_type=$7
centos_version=$8

source centos-install-utilities.sh #Allows access to utilities functions
source shared-utilities.sh

initial_setup true
setup_ssh true fluffee 7901
install_lxtask true 64
create_user true fluffee botting
install_java true 64
install_vnc true 64
setup_firefox true
setup_bots true fluffee
create_resolution_change fluffee
setup_vnc true 15310 fluffee botting
setup_desktop_environment fluffee
enable_jar_doubleclick fluffee
