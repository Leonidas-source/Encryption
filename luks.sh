#!/bin/bash
error() {
  clear
  echo "You must be root to execute this script"
  exit
}
user_check() {
  clear
  [ `/usr/bin/whoami` != root ] && error
}
iamtoolazy() {
  clear
  mount /dev/mapper/secret /mnt
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
  echo "Set your mode
  1) fill drive with zeroes
  2) create partition table
  3) encrypt partition with key file
  4) encrypt partition with passphrase
  5) create filesystem
  6) open partition with key file
  7) open partition with passphrase
  8) exit"
  read answr
  [ "$answr" == "1" ] && disk
  [ "$answr" == "2" ] && table
  [ "$answr" == "3" ] && crypt
  [ "$answr" == "4" ] && crypt_with_password
  [ "$answr" == "5" ] && fs
  [ "$answr" == "6" ] && open
  [ "$answr" == "7" ] && open_with_password
  [ "$answr" == "8" ] && exit
}
disk() {
  clear
  lsblk
  echo "set your drive"
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
  cfdisk $drive
  clear
  menu
}
crypt() {
  random
  clear
  lsblk
  echo "set your future encrypt partition"
  read part
  umount $part
  clear
  cryptsetup --type luks2 luksFormat --key-file=key $part
  menu
}
crypt_with_password() {
  clear
  lsblk
  echo "set your future encrypt partition"
  read part
  umount $part
  clear
  cryptsetup --type luks2 luksFormat $part
  menu
}
fs() {
  clear
  echo "set your filesystem for encrypted partition
  1) ext4
  2) btrfs
  3) exfat
  4) vfat(fat32)
  5) ntfs"
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
  echo "set partition"
  read deep
  cryptsetup open $deep secret --key-file key
  menu
}
open_with_password() {
  clear
  lsblk
  echo "set partition"
  read deep_password
  cryptsetup open $deep_password secret
  menu
}
user_check
menu
