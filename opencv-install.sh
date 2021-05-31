
echo "Please enter opencv version full name : (sample ==> 4.5.2) "
# echo -e '\e]8;;https://github.com/opencv/opencv/releases/\aView last version here\e]8;;\a'  
firefox https://github.com/opencv/opencv/releases/

read version

# Detect Debian users running the script with "sh" instead of bash
if readlink /proc/$$/exe | grep -q "dash"; then
	echo 'This installer needs to be run with "bash", not "sh".'
	exit
fi

# Discard stdin. Needed when running from an one-liner which includes a newline
read -N 999999 -t 0.001

# Detect version
if [[ $(uname -r | cut -d "." -f 1) -eq 2 ]]; then
	echo "The system is running an old kernel, which is incompatible with this installer."
	exit
fi

# Detect OS
# $os_version variables aren't always in use, but are kept here for convenience
if grep -qs "ubuntu" /etc/os-release; then
	os="ubuntu"
	os_version=$(grep 'VERSION_ID' /etc/os-release | cut -d '"' -f 2 | tr -d '.')
	group_name="nogroup"
else
	echo "This installer seems to be running on an unsupported distribution.
Supported distributions are Ubuntu, Debian, CentOS, and Fedora."
	exit
fi

if [[ "$os" == "ubuntu" && "$os_version" -lt 1804 ]]; then
	echo "Ubuntu 18.04 or higher is required to use this installer.
This version of Ubuntu is too old and unsupported."
	exit
fi

# Detect environments where $PATH does not include the sbin directories
if ! grep -q sbin <<< "$PATH"; then
	echo '$PATH does not include sbin. Try using "su -" instead of "su".'
	exit
fi

# if [[ "$EUID" -ne 0 ]]; then
# 	echo "This installer needs to be run with superuser privileges."
# 	exit
# fi

if [[ "$os" = "debian" || "$os" = "ubuntu" ]]; then
		sudo apt update
		apt-get install -y  build-essential cmake git pkg-config libgtk-3-dev \
		libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
		libxvidcore-dev libx264-dev libjpeg-dev libpng-dev libtiff-dev \
		gfortran openexr libatlas-base-dev python3-dev python3-numpy \
		libtbb2 libtbb-dev libdc1394-22-dev libopenexr-dev \
		libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev
fi
pwd_base=$pwd
echo $pwd_base
mkdir opencv_build 
cd opencv_build

wget -O opencv.zip https://github.com/opencv/opencv/archive/refs/tags/$version.zip
# wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/refs/tags/$version.zip

unzip opencv.zip 
# unzip opencv_contrib.zip 
pwd
cd opencv-$version
pwd
mkdir -p build 
cd build
pwd
cmake -D CMAKE_BUILD_TYPE=RELEASE \
-D CMAKE_INSTALL_PREFIX=/usr/local \
-D INSTALL_C_EXAMPLES=ON \
-D INSTALL_PYTHON_EXAMPLES=ON \
-D OPENCV_GENERATE_PKGCONFIG=ON \
-D BUILD_EXAMPLES=ON ..

echo "config is correct?(y/n)"
read x
if [ "$x" = "n" ]; then
    exit 
fi

echo "what is number of cpu cores to build?(1-8)"

read cpu_cores

make -j$cpu_cores

make install
