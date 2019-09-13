#!/bin/bash

# Must be root
if [ $(id -u) -ne 0 ]; then
  printf "Must be root. Did you use 'sudo'?\n"
  exit 1
fi

printf "\nInstalling packages...\n"
sudo apt-get update
sudo apt-get install motion

printf "\nInstalling files...\n"
sudo cp -rv pkg/* /

printf "\nEnabling services...\n"
sudo systemctl daemon-reload
sudo systemctl start motion

printf "\nDONE.\n"
