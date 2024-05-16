#!bin/bash

sudo apt-get update

sudo apt-get install git-all -y

sudo apt-get install openssh-client -y

mkdir /home/jupyter/ssh_keys

# Replace with your github account email
ssh-keygen -t ed25519 -C "your_email@example.com"

eval "$(ssh-agent -s)"

ssh-add /home/jupyter/ssh_keys/id_ed25519