#!/bin/bash
sudo mount /dev/sda4 /run/media/
rsync --force  -a --delete --quiet /home/OneDrive/UAB/Matemàtiques/3r/Teoria\ de\ Galois/Teoria/ /home/Desktop/prova
sudo umount /dev/sda4
# rsync --force  -a --delete --quiet ~/OneDrive/UAB/Matemàtiques/3r/A ~/Desktop/prova
