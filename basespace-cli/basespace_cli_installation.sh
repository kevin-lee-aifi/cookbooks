#!/usr/bin/bash

# ----------------------------------------------------------
# INSTRUCTIONS

# Copy/paste the following command and run it in the terminal: source [SHELL_SCRIPT_PATH]

# ----------------------------------------------------------

mkdir -p /home/jupyter/basespace # Create new directory to store basespace cli

wget "https://launch.basespace.illumina.com/CLI/latest/amd64-linux/bs" -O /home/jupyter/basespace/bs # Download basespace cli

chmod u+x /home/jupyter/basespace/bs # Enables executable permissions for basespace cli file

alias bs='/home/workspace/basespace/bs' # Creates bs alias command in place of /home/jupyter/basespace/bs