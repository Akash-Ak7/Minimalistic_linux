#!/bin/bash
#
# This script will initialize global variables and extend generic functionality.
#
# Kernel and Busybox version
KERNEL_VERSION=5.9.4
BUSYBOX_VERSION=1.35.0

KERNEL_MAJOR=$(echo $KERNEL_VERSION | sed 's/\([0-9]*\)[^0-9].*/\1/')
BUILD_NUMBER=$(echo ${KERNEL_VERSION}${BUSYBOX_VERSION} | sed -e "s/\.//g")

# Directory variables
cd ..
BASE_DIR=$PWD
cd ./source

BUILD_DIR="mini_linux_"$BUILD_NUMBER
WORK_DIR=./build/$BUILD_DIR/work

DEPENDENCY=(libncurses-dev flex bison openssl libssl-dev dkms libelf-dev libudev-dev libpci-dev libiberty-dev autoconf)

#===============================================
# To print error messages
#
# Arguments:
#       Error statement to be printed
# Output:
#       None
#==============================================
error()
{
    echo "[Error]: $*" >&2
}