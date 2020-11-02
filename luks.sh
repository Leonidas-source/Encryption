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
open() {
  clear
  lsblk
  echo "set partition"
  read deep
  cryptsetup open $deep secret --key-file key
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
  [ $answr2 == "1" ] && mkfs.ext4 /dev/mapper/secret
  [ $answr2 == "2" ] && mkfs.btrfs /dev/mapper/secret
  [ $answr2 == "3" ] && mkfs.exfat /dev/mapper/secret
  [ $answr2 == "4" ] && mkfs.vfat /dev/mapper/secret
  [ $answr2 == "5" ] && mkfs.ntfs /dev/mapper/secret
  iamtoolazy
  menu
}
table() {
  clear
  cfdisk $drive
  clear
  sleep 3s
  lsblk
  echo "set your future encrypt partition"
  read part
  clear
  menu
}
crypt() {
  clear
  cryptsetup --type luks2 --hash sha512 luksFormat --key-file=key $part
  cryptsetup open $part secret --key-file key
  menu
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
menu() {
  clear
  echo "Set your mode
  1) create a key
  2) fill drive with zeroes
  3) create partition table
  4) encrypt partition
  5) create filesystem
  6) open partition
  7) exit"
  read answr
  [ $answr == "1" ] && random
  [ $answr == "2" ] && disk
  [ $answr == "3" ] && table
  [ $answr == "4" ] && crypt
  [ $answr == "5" ] && fs
  [ $answr == "6" ] && open
  [ $answr == "7" ] && exit
}
random() {
  clear
  dd if=/dev/random of=key bs=1M count=7 iflag=fullblock status=progress
  menu
}
user_check
menu
