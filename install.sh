#!/bin/bash
set -e  # Any error will cause the script to fail

# Redirects output on &3 to /dev/null unless -v or --verbose is passed 
if [ "$1" = "-v" ]; then
  exec 3>&1
else
  exec 3>/dev/null
fi

echo "Cloning submodules..."
git submodule update --init >&3

echo "Building OpenCV. This could take up to 10 minutes..."
cd opencv_ffi
./build.sh >&3
cd ..

cd video/src
if [ ! -f /usr/local/lib/librealsense2.so ]
then
  echo "Compiling librealsense. This could take up to 45 minutes..."
  sh build.sh
fi
echo "Compiling RealSense FFI..."
make shared
cd ../..

echo "Compiling the video program. This could take up to a minute..."
cd video
dart pub get >&3
dart compile exe bin/video.dart -o ~/video.exe >&3
cd ..

echo "Installing configuration files..."
sudo cp ./10-cameras.rules /etc/udev/rules.d
sudo cp ./video.service /etc/systemd/system
sudo systemctl enable video >&3
sudo systemctl start video >&3
sudo udevadm control --reload-rules
sudo udevadm trigger

echo ""
echo "Done! Here's what just happened"
echo "- OpenCV was built and installed as a dynamic library"
echo "- The video program was compiled to ~/video.exe"
echo "- udev will auto-detect cameras when plugged in"
echo "- systemd will auto-start the video program on boot"
