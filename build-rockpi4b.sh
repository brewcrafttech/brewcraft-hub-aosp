#!/bin/bash

########################################################################################################################
## This builds for RockPi 4B ONLY!!!
########################################################################################################################

BRANCH=BrewHub_Rock4B
LUNCH=rk3399_ROCKPI4B_Android11_BrewHub-userdebug
UBOOT_TARGET=rockpi4b
KERNEL_CONFIG=rockpi_4b.config
KERNEL_IMAGE=rk3399-rockpi-4b.img
AOSP_IMAGE=Image-rk3399_ROCKPI4B_Android11

########################################################################################################################

# Download the repo tool
wget 'https://storage.googleapis.com/git-repo-downloads/repo' -P /tmp/
cp /tmp/repo /usr/local/bin/repo
chmod +x /usr/local/bin/repo

# Install python 3.8
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y software-properties-common
add-apt-repository -y ppa:deadsnakes/ppa
add-apt-repository -y universe
apt-get update -y
apt-get install -y python3.8
apt-get install -y python3.8-distutils
apt-get install -y python3.8-dev
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 150
apt-get install -y python3-pip
pip install pycryptodome

# Install build dependencies
apt-get install -y openjdk-8-jdk git-core gnupg flex bison gperf build-essential \
  zip curl gawk liblz4-tool zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 \
  libncurses5-dev libncursesw5-dev x11proto-core-dev libx11-dev lib32z-dev ccache \
  libgl1-mesa-dev libxml2-utils xsltproc unzip mtools u-boot-tools \
  htop iotop sysstat iftop pigz bc device-tree-compiler lunzip \
  dosfstools vim-common parted udev libssl-dev sudo rsync python3-pyelftools cpio

# Install libncurses5
wget http://archive.ubuntu.com/ubuntu/pool/universe/n/ncurses/libtinfo5_6.4-2_amd64.deb
dpkg -i libtinfo5_6.4-2_amd64.deb
wget http://archive.ubuntu.com/ubuntu/pool/universe/n/ncurses/libncurses5_6.4-2_amd64.deb
dpkg -i libncurses5_6.4-2_amd64.deb

# Install python 2.7
sudo apt install -y checkinstall libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev
wget https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz
tar -xvf Python-2.7.18.tgz
cd Python-2.7.18
./configure --enable-optimizations
make -j4 build_all
make install
cd ..
rm -rf Python-2.7.18
rm Python-2.7.18.tgz

# Setup git config
git config --global user.email "aosp-builder@brewcraft.tech"
git config --global user.name "AOSP Builder"

# Create a build directory
mkdir build
cd build

# Initialize the repo
yes | repo init -u https://github.com/brewcrafttech/brewcraft-hub-aosp.git -b $BRANCH -m rockchip-r-release.xml
repo sync -d --no-tags -j4

# TODO: install overlay
cd ..
cp -R -v ./overlay/* ./build/
cd build

# Build the bootloader
cd u-boot
make clean
make mrproper
make distclean
./make.sh $UBOOT_TARGET
cd ..

# Build the kernel
cd kernel
export ADDON_ARGS="CC=../prebuilts/clang/host/linux-x86/clang-r383902b/bin/clang LD=../prebuilts/clang/host/linux-x86/clang-r383902b/bin/ld.lld"
make clean
make $ADDON_ARGS ARCH=arm64 rockchip_defconfig android-11.config $KERNEL_CONFIG
make $ADDON_ARGS ARCH=arm64 $KERNEL_IMAGE -j$(nproc)
cd ..

# Build AOSP
source build/envsetup.sh
lunch $LUNCH
make -j$(nproc)

# Generate image
rm -rf rockdev
ln -s RKTools/linux/Linux_Pack_Firmware/rockdev .
./mkimage.sh

# Build GPT image
cd rockdev
ln -s $AOSP_IMAGE Image
./android-gpt.sh
# TODO: build artifact: gpt.img (maybe this should happen in the git action?)
#       build/rockdev/Image/gpt.img
cd ..
