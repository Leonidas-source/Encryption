#!/bin/bash
red="\e[0;91m"
blue="\e[0;94m"
expand_bg="\e[K"
blue_bg="\e[0;104m${expand_bg}"
red_bg="\e[0;101m${expand_bg}"
green_bg="\e[0;102m${expand_bg}"
green="\e[0;92m"
white="\e[0;97m"
bold="\e[1m"
uline="\e[4m"
reset="\e[0m"
error() {
  clear
  echo -e "${green}${bold}You must be root to execute this script${reset}"
  exit
}
user_check() {
  clear
  [ `/usr/bin/whoami` != root ] && error
}
iamtoolazy() {
  clear
  mount -o rw /dev/mapper/secret /mnt
  chmod -R 777 /mnt
  umount /mnt
}
random() {
  clear
  dd if=/dev/random of=key bs=1M count=7 iflag=fullblock status=progress
  menu
}
menu() {
  clear
  echo -e "${green}${bold}Set your mode
  1) fill drive with zeroes
  2) create partition table
  3) encrypt partition with key file
  4) encrypt partition with passphrase
  5) create filesystem
  6) open encrypted partition
  7) close encrypted partition
  8) create encrypted container
  9) open encrypted container
  10) close encrypted container
  11) mount encrypted container
  12) umount encrypted container
  13) exit${reset}"
  read answr
  [ "$answr" == "1" ] && disk
  [ "$answr" == "2" ] && table
  [ "$answr" == "3" ] && crypt
  [ "$answr" == "4" ] && crypt_with_password
  [ "$answr" == "5" ] && fs
  [ "$answr" == "6" ] && check_key
  [ "$answr" == "7" ] && close
  [ "$answr" == "8" ] && container
  [ "$answr" == "9" ] && open_container
  [ "$answr" == "10" ] && close_container
  [ "$answr" == "11" ] && count_mount
  [ "$answr" == "12" ] && count_umount
  [ "$answr" == "13" ] && exit
}
count_mount() {
  clear
  ls | grep -w "folder" || mkdir folder
  name=$(cat conf | sed -n "1p")
  options=$(cat conf | sed -n "2p")
  mount -o rw /dev/mapper/$name $options folder
  menu
}
count_umount() {
  clear
  umount folder
  menu
}
open_container() {
  clear
  name=$(cat conf | sed -n "1p")
  ls | grep -w "container.img" || (echo -e "${green}${bold}container not found${reset}" && exit)
  cryptsetup open container.img $name || exit
  menu
}
close_container() {
  clear
  ls | grep -w "container.img" || (echo -e "${green}${bold}container not found${reset}" && exit)
  name=$(cat conf | sed -n "1p")
  cryptsetup close /dev/mapper/$name || exit
  menu
}
close() {
  clear
  lsblk
  echo -e "${green}${bold}set your partition${reset}"
  read closed
  cryptsetup close /dev/mapper/secret
  menu
}
check_key() {
  clear
  ls | grep -w "key" && open
  open_with_password
}
disk() {
  clear
  lsblk
  echo -e "${green}${bold}set your drive${reset}"
  read drive
  umount $drive'1'
  umount $drive'2'
  umount $drive'3'
  umount $drive'4'
  umount $dirve'5'
  umount $drive'6'
  umount $drive'7'
  umount $drive'8'
  umount $drive'9'
  umount $drive'10'
  clear
  dd if=/dev/zero of=$drive status=progress
  menu
}
table() {
  clear
  lsblk
  echo -e "${green}${bold}set your drive${reset}"
  read drive2
  cfdisk $drive2
  clear
  menu
}
crypt() {
  random
  clear
  lsblk
  echo -e "${green}${bold}set your future encrypt partition${reset}"
  read part
  umount $part
  clear
  cryptsetup --type luks2 luksFormat --key-file=key $part
  menu
}
crypt_with_password() {
  clear
  lsblk
  echo -e "${green}${bold}set your future encrypt partition${reset}"
  read part
  umount $part
  clear
  cryptsetup --type luks2 luksFormat $part
  menu
}
fs() {
  clear
  echo -e "${green}${bold}set your filesystem for encrypted partition
  1) ext4
  2) btrfs
  3) exfat
  4) vfat(fat32)
  5) ntfs${reset}"
  read answr2
  [ "$answr2" == "1" ] && mkfs.ext4 /dev/mapper/secret
  [ "$answr2" == "2" ] && mkfs.btrfs /dev/mapper/secret
  [ "$answr2" == "3" ] && mkfs.exfat /dev/mapper/secret
  [ "$answr2" == "4" ] && mkfs.vfat /dev/mapper/secret
  [ "$answr2" == "5" ] && mkfs.ntfs /dev/mapper/secret
  iamtoolazy
  menu
}
open() {
  clear
  lsblk
  echo -e "${green}${bold}set partition${reset}"
  read deep
  cryptsetup open $deep secret --key-file key
  menu
}
open_with_password() {
  clear
  lsblk
  echo -e "${green}${bold}set partition${reset}"
  read deep_password
  cryptsetup open $deep_password secret
  menu
}
use_conf_file() {
  clear
  answr3=$(cat conf | sed -n "1p")
}
fs1() {
  ls | grep -w "conf" && use_conf_file || (echo "set name for your container" && read answr3 && echo $answr3 | cat >> conf)
  answr3=$(cat conf | sed -n "1p")
  cryptsetup open container.img $answr3
  echo -e "${green}${bold}set your filesystem for encrypted partition
  1) ext4
  2) btrfs
  3) exfat
  4) vfat(fat32)
  5) ntfs${reset}"
  read fs_for_container
  [ "$fs_for_container" == "1" ] && mkfs.ext4 /dev/mapper/$answr3
  [ "$fs_for_container" == "2" ] && mkfs.btrfs /dev/mapper/$answr3 && btrfser
  [ "$fs_for_container" == "3" ] && mkfs.exfat /dev/mapper/$answr3
  [ "$fs_for_container" == "4" ] && mkfs.vfat /dev/mapper/$answr3
  [ "$fs_for_container" == "5" ] && mkfs.ntfs /dev/mapper/$answr3
  mount -o rw /dev/mapper/$answr3 /mnt && chmod -R 777 /mnt && umount /mnt
}
btrfser() {
  clear
  echo -e "${green}${bold}set your compression type
  1) zlib
  2) lzo
  3) zstd
  4) no compression${reset}"
  read compression_type
  [ "$compression_type" == "1" ] && echo "-o compress-force=zlib" | cat >> conf
  [ "$compression_type" == "2" ] && echo "-o compress-force=lzo" | cat >> conf
  [ "$compression_type" == "3" ] && echo "-o compress-force=zstd" | cat >> conf
  [ "$compression_type" == "4" ] && echo "-o compress=no" | cat >> conf
}
container() {
  clear
  ls | grep -w "container.img" && already_exist
  echo -e "${green}${bold}set container size(GB)${reset}"
  read size
  dd if=/dev/zero of=container.img bs=1024M count=$size status=progress
  clear
  cryptsetup --type luks2 luksFormat container.img
  clear
  fs1
  menu
}
already_exist() {
  clear
  echo -e "${green}${bold}container already exist, what to do with it?
  1) remove container
  2) reformat container
  3) format container(first attempt failed)${reset}"
  read attempt
  [ "$attempt" == "1" ] && rm container.img && menu
  [ "$attempt" == "2" ] && reformat && menu
  [ "$attempt" == "3" ] && fs1 && menu
}
reformat() {
  clear
  name=$(cat conf)
  cryptsetup open container.img $name
  echo -e "${green}${bold}set your filesystem for encrypted partition
  1) ext4
  2) btrfs
  3) exfat
  4) vfat(fat32)
  5) ntfs${reset}"
  read fs_for_container
  [ "$fs_for_container" == "1" ] && mkfs.ext4 -f /dev/mapper/$name
  [ "$fs_for_container" == "2" ] && mkfs.btrfs -f /dev/mapper/$name
  [ "$fs_for_container" == "3" ] && mkfs.exfat -f /dev/mapper/$name
  [ "$fs_for_container" == "4" ] && mkfs.vfat -f /dev/mapper/$name
  [ "$fs_for_container" == "5" ] && mkfs.ntfs -f /dev/mapper/$name
}
user_check
menu
clear
