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
  6) open encrypted partition
  7) close encrypted partition
  8) create encrypted container
  9) open encrypted container
  10) close encrypted container
  11) exit"
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
  [ "$answr" == "11" ] && exit
}
open_container() {
  clear
  ls | grep -w "container.img" || (echo "container not found" && exit)
  cryptsetup open container.img secret_container || exit
  menu
}
close_container() {
  clear
  ls | grep -w "container.img" || (echo "container not found" && exit)
  cryptsetup close /dev/mapper/secret_container || exit
  menu
}
close() {
  clear
  lsblk
  echo "set your partition"
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
  lsblk
  echo "set your drive"
  read drive2
  cfdisk $drive2
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
fs1() {
  cryptsetup open container.img secret_container
  echo "set your filesystem for encrypted partition
  1) ext4
  2) btrfs
  3) exfat
  4) vfat(fat32)
  5) ntfs"
  read fs_for_container
  [ "$fs_for_container" == "1" ] && mkfs.ext4 /dev/mapper/secret_container
  [ "$fs_for_container" == "2" ] && mkfs.btrfs /dev/mapper/secret_container
  [ "$fs_for_container" == "3" ] && mkfs.exfat /dev/mapper/secret_container
  [ "$fs_for_container" == "4" ] && mkfs.vfat /dev/mapper/secret_container
  [ "$fs_for_container" == "5" ] && mkfs.ntfs /dev/mapper/secret_container
}
container() {
  clear
  ls | grep -w "container.img" && already_exist
  echo "set container size(GB)"
  read size
  dd if=/dev/zero of=container.img bs=1024M count=$size status=progress
  cryptsetup --type luks2 luksFormat container.img
  fs1
  menu
}
already_exist() {
  clear
  echo "container already exist, what to do with it?
  1) remove container
  2) reformat container
  3) format container(first attempt failed)"
  read attempt
  [ "$attempt" == "1" ] && rm container.img && menu
  [ "$attempt" == "2" ] && reformat && menu
  [ "$attempt" == "3" ] && fs1 && menu
}
reformat() {
  clear
  cryptsetup open container.img secret_container
  echo "set your filesystem for encrypted partition
  1) ext4
  2) btrfs
  3) exfat
  4) vfat(fat32)
  5) ntfs"
  read fs_for_container
  [ "$fs_for_container" == "1" ] && mkfs.ext4 -f /dev/mapper/secret_container
  [ "$fs_for_container" == "2" ] && mkfs.btrfs -f /dev/mapper/secret_container
  [ "$fs_for_container" == "3" ] && mkfs.exfat -f /dev/mapper/secret_container
  [ "$fs_for_container" == "4" ] && mkfs.vfat -f /dev/mapper/secret_container
  [ "$fs_for_container" == "5" ] && mkfs.ntfs -f /dev/mapper/secret_container
}
user_check
menu
