#!/bin/bash

# Must be root
if [ $(id -u) -ne 0 ]; then
  printf "Must be root. Did you use 'sudo'?\n"
  exit 1
fi

printf "\nInstalling packages...\n"
sudo apt-get update
sudo apt-get install -y fbi gstreamer1.0-tools gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-omx

printf "\nInstalling files...\n"
sudo cp -rv pkg/* /

# TODO: copy pkg/home/pi/* files to appropriate home directory. How can we know what user is to be run under?
#shopt -s dotglob ;# bash will not find hidden .xxx files and complain, fix it with dotglob
#sudo cp -rv pkg/home/pi/* ~/
#shopt -u dotglob ;# restore

printf "\nEnabling services...\n"
sudo systemctl daemon-reload
sudo systemctl start webcam-video.service
sudo systemctl enable webcam-video.service
sudo systemctl enable splashscreen.service

printf "\nPrevent screen blanking...\n"
echo 0 | sudo tee /sys/class/graphics/fb0/blank >/dev/null

printf "\nDONE.\n"
