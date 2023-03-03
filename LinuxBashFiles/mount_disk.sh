#!/bin/bash

if [ "$1" = "-?" ]; then
	echo "notes: "
	echo "this script will enum avilable /dev/sd* and mount then under /disk"
	echo "each time you execute this script, umount /disk* will work firstly"
	echo "you can use param -u [means umount] to control the script only do "
	echo "umount works and then exit automatically"      
	exit
fi

if [ ! `whoami` = root ]; then
	echo "neet root priviledge"
	exit
fi


echo "------------umount disks------------------" > mount.log
if [ -d /disk ]; then
	for f in `ls /disk`; do
		echo "===> try umount /disk/$f" >> mount.log
		umount /disk/$f >> mount.log 2>&1
	done
	echo "umount finish, rm all dirs under /disk" >> mount.log
	rm -d /disk/* >> mount.log 2>&1
fi

if [ "$1" = "-u" ]; then
        echo "umount ok"
	exit
fi

echo "------------mount disks------------------" >> mount.log
if [ ! -d /disk ]; then
	mkdir /disk
	#echo "mkdir /disk"
fi

for sd in `fdisk -l 2>/dev/null | grep ^/dev/sd | cut -d' ' -f1 | cut -d'/' -f3`
do
	echo "===> try mount /dev/$sd" >> mount.log
	if [ ! -d /disk/$sd ]; then
		echo "mkdir /disk/$sd" >> mount.log
		mkdir /disk/$sd >> mount.log 2>&1
	fi
	mount /dev/$sd /disk/$sd >> mount.log 2>&1
	if [ $? = 0 ]; then
		echo "mount /dev/$sd succeed" >> mount.log
	else
		echo "mount /dev/$sd faild, rm /disk/$sd" >> mount.log
		rm -d /disk/$sd
	fi
done

echo "finished, all disk has been mounted under /disk. for detail, see the mount.log file"	
