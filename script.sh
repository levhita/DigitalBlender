#!/bin/bash
#snap install blender --classic
#wget https://mirror.clarkson.edu/blender/release/Blender2.79/blender-2.79b-linux-glibc219-x86_64.tar.bz2
#tar xvjf blender-2.79b-linux-glibc219-x86_64.tar.bz2
#cd blender-2.79b-linux-glibc219-x86_64/
apt-get update
apt-get install -y libglu1-mesa libxi6 libxrender1 unzip
snap install blender --classic