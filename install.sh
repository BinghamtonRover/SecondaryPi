#!/bin/bash
# All stdout here is redirected to /dev/null, but leave stderr alone!
set -e  # Any error will cause the script to fail

echo "Cloning submodules..."
git submodule update --init > /dev/null

echo "Building OpenCV. This could take up to 10 minutes..."
cd opencv_ffi
./build.sh >/dev/null
# Add this export to ~/.bashrc if it's not already there
if ! grep -Exq "export LD_LIBRARY_PATH.+opencv_ffi/dist" ~/.bashrc
then
  echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$(pwd)/dist" >> ~/.bashrc
fi
cd ..

echo "Compiling the video program. This could take about 1 minute..."
cd video
dart pub get > /dev/null
dart compile exe bin/video.dart -o ~/video.exe > /dev/null
cd ..

echo "Installing configuration files..."
sudo cp ./10-cameras.rules /etc/udev/rules.d
sudo cp ./video.service /etc/systemd/system
sudo systemctl enable video > /dev/null
sudo systemctl start video > /dev/null
sudo udevadm control --reload-rules
sudo udevadm trigger

echo ""
echo "Done! Here's what just happened"
echo "- OpenCV was built and installed as a dynamic library"
echo "- The video program was compiled to ~/video.exe"
echo "- udev will auto-detect cameras when plugged in"
echo "- systemd will auto-start the video program on boot"
