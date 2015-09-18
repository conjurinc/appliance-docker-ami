#!/bin/bash -ex
sudo apt-get update

# Some trickery from http://serverfault.com/questions/662624/how-to-avoid-grub-errors-after-runing-apt-get-upgrade-ubunut [sic]
sudo rm /boot/grub/menu.lst
sudo update-grub-legacy-ec2 -y
# end trickery

sudo apt-get dist-upgrade -yqq

sudo reboot
sleep 60
