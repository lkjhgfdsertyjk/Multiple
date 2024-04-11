#!/bin/bash

# Create subfolders
mkdir -p tools

# Install Sublist3r
echo "Installing Sublist3r..."
cd tools/
git clone https://github.com/aboul3la/Sublist3r.git
cd Sublist3r
sudo pip install -r requirements.txt
sudo pip install requests
sudo pip install dnspython
sudo pip install argparse

# Install Eyewitness
echo "Installing Eyewitness..."
cd ..
git clone https://github.com/RedSiege/EyeWitness.git
cd EyeWitness/Python/setup
./setup.sh
cd ~
