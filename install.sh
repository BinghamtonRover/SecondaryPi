set -e  # Any error will cause the script to fail

echo "Cloning submodules..."
git submodule update --init

echo "Building OpenCV..."
cd opencv_ffi
./build.sh
echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$(pwd)/dist" >> ~/.bashrc
cd ..

echo "Compiling the video program..."
cd video
dart pub get
dart compile exe bin/video.dart -o ~/video.exe
cd ..

echo "Installing configuration files..."
sudo cp 10-camera.rules /etc/udev/rules.d
sudo cp video.service /etc/systemd/system

echo "Done! Here's what just happened"
echo "- OpenCV was built and installed as a dynamic library"
echo "- The video program was compiled to ~/video.exe"
echo "- The rover will auto-detect cameras when plugged in"
echo "- The rover will auto-start the video program on boot"
