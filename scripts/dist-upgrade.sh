#!/bin/bash -ex
apt-get update

# Some trickery from http://serverfault.com/questions/662624/how-to-avoid-grub-errors-after-runing-apt-get-upgrade-ubunut [sic]
rm /boot/grub/menu.lst
update-grub-legacy-ec2 -y
# end trickery

apt-get dist-upgrade -yqq

reboot
sleep 60
