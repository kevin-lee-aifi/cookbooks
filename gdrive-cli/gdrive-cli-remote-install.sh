#!/usr/bin/bash

# Create and activate the conda environment (COMMENT OUT IF INSTALLING ON ROOT ENVIRONMENT)
conda create -y --prefix envs/workflow_envs python=3.9
conda activate "/home/jupyter/visium_analysis_workflow/envs/workflow_envs"

# Download and install gdrive
GDRIVE_URL="https://github.com/glotlabs/gdrive/releases/download/3.9.1/gdrive_linux-x64.tar.gz"
GDRIVE_BIN="gdrive_linux-x64.tar.gz"

# Download gdrive binary
curl -L -o ${GDRIVE_BIN} ${GDRIVE_URL}

# Extract the tar file
tar -xzf ${GDRIVE_BIN}

# Make gdrive executable and move it to /usr/local/bin
chmod +x gdrive
sudo mv gdrive /usr/local/bin/

# Clean up
rm ${GDRIVE_BIN}

# Authenticate gdrive (This part requires manual intervention for the first time)
echo "Please run 'gdrive about' in your terminal and follow the instructions to authenticate gdrive with your Google account."