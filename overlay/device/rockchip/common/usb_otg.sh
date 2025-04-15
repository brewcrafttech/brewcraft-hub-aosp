#! /vendor/bin/sh

check_count=5
con_path='sys/devices/platform/ff770000.syscon/ff770000.syscon:usb2-phy@e450/otg_mode'


while [ $check_count -gt 0 ];do
if [ -e $con_path ]
then
	if [ $? -eq 0 ];then
		echo peripheral > $con_path
	break
else
	sleep 1
	check_count=$(( $check_count - 1 ))
	fi

fi
done
exit 0
