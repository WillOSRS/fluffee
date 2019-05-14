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

initial_setup ${verbose} ${bit_type} ${centos_version}
setup_ssh ${verbose} ${user_name} ${ssh_port}
install_lxtask ${verbose} ${bit_type}
install_fbpanel ${verbose} ${bit_type} ${centos_version}
create_user ${verbose} ${user_name} ${account_password}
install_java ${verbose} ${bit_type}
install_vnc ${verbose} ${bit_type}
setup_bots ${verbose} ${user_name}
create_resolution_change ${user_name}
setup_desktop ${verbose} ${user_name}
setup_vnc ${verbose} ${vnc_port} ${user_name} ${vnc_password} centos
enable_jar_doubleclick ${user_name}