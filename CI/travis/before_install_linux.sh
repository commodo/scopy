#!/bin/bash
set -e

. CI/travis/lib.sh

patch_qwtpolar_linux() {
	patch_qwtpolar

	patch -p1 <<-EOF
--- a/qwtpolarconfig.pri
+++ b/qwtpolarconfig.pri
@@ -16,7 +16,9 @@ QWT_POLAR_VER_PAT      = 1
 QWT_POLAR_VERSION      = \$\${QWT_POLAR_VER_MAJ}.\$\${QWT_POLAR_VER_MIN}.\$\${QWT_POLAR_VER_PAT}
 
 unix {
-    QWT_POLAR_INSTALL_PREFIX    = /usr/local/qwtpolar-\$\$QWT_POLAR_VERSION
+    QWT_POLAR_INSTALL_PREFIX    = $STAGINGDIR
+    QMAKE_CXXFLAGS              = -I${STAGINGDIR}/include
+    QMAKE_LFLAGS                = -L${STAGINGDIR}/lib
 }
 
 win32 {
EOF
}

handle_ubuntu_flatpak_docker() {
	sudo apt-get -qq update
	sudo service docker restart
	sudo docker pull alexandratr/ubuntu-flatpak-kde:latest
}

handle_ubuntu_docker() {
	sudo apt-get -qq update
	sudo service docker restart
	sudo docker pull ubuntu:${OS_VERSION}
}

handle_centos_docker() {
	sudo apt-get -qq update
	sudo service docker restart
	sudo docker pull centos:${OS_VERSION}
}

handle_default() {
	pwd
	ls

	if [ -z "${LDIST}" -a -f "build/.LDIST" ] ; then
		export LDIST="-$(cat build/.LDIST)"
	fi
	if [ -z "${LDIST}" ] ; then
		export LDIST="-$(get_ldist)"
	fi

	BOOST_PACKAGES_BASE="libboost libboost-regex libboost-date-time
		libboost-program-options libboost-test libboost-filesystem
		libboost-system libboost-thread"

	for package in $BOOST_PACKAGES_BASE ; do
		BOOST_PACKAGES="$BOOST_PACKAGES ${package}${BOOST_VER}-dev"
	done

	sudo apt-get -qq update
	sudo apt-get install -y build-essential g++ bison flex libxml2-dev libglibmm-2.4-dev \
		libmatio-dev libglib2.0-dev libzip-dev libfftw3-dev libusb-dev doxygen \
		qt5-default qttools5-dev qtdeclarative5-dev libqt5svg5-dev libqt5opengl5-dev \
		libvolk1-dev libsigrok-dev libsigrokcxx-dev libsigrokdecode-dev \
		python-cheetah cmake gnuradio-dev $BOOST_PACKAGES

	QMAKE="$(command -v qmake)"

	for pkg in libiio libad9361-iio ; do
		wget http://swdownloads.analog.com/cse/travis_builds/master_latest_${pkg}${LDIST}.deb
		sudo dpkg -i ./master_latest_${pkg}${LDIST}.deb
	done

	qmake_build_git "qwt" "https://github.com/osakared/qwt.git" "qwt-6.1-multiaxes" "qwt.pro" "patch_qwt"

	qmake_build_wget "qwtpolar-1.1.1" "https://downloads.sourceforge.net/project/qwtpolar/qwtpolar/1.1.1/qwtpolar-1.1.1.tar.bz2" "qwtpolar.pro" "patch_qwtpolar_linux"

	cmake_build_git "gr-iio" "https://github.com/analogdevicesinc/gr-iio"
}

handle_centos() {
	ls

	yum install -y epel-release

	yum -y groupinstall 'Development Tools'

	yum -y update

	yum -y install cmake3 gcc bison boost-devel python2-devel python36 libxml2-devel libzip-devel \
		fftw-devel bison flex yum matio-devel glibmm24-devel glib2-devel doxygen \
		swig git libusb1-devel doxygen python-six python-mako \
		rpm rpm-build libxml2-devel \
		python-cheetah wget tar autoconf autoconf-archive \
		libffi-devel libmount-devel pcre2-devel cppunit-devel gnuradio-devel
		python3 python3-devel \
		qt5-qtbase qt5-qtbase-common qt5-qtbase-devel qt5-qtbase-gui \
		qt5-qtdeclarative-devel qt5-qtquickcontrols \
		qt5-qtsvg-devel qt5-qttools-devel qt5-qttools-static qt5-qtscript automake \
		libtool libglvnd-glx libstdc++ mesa-libEGL

	qmake_build_git "qwt" "https://github.com/osakared/qwt.git" "qwt-6.1-multiaxes" "qwt.pro" "patch_qwt"

	qmake_build_wget "qwtpolar-1.1.1" "https://downloads.sourceforge.net/project/qwtpolar/qwtpolar/1.1.1/qwtpolar-1.1.1.tar.bz2" "qwtpolar.pro" "patch_qwtpolar_linux"

	cmake_build_git "gr-iio" "https://github.com/analogdevicesinc/gr-iio"
}

OS_TYPE=${1:-default}
OS_VERSION=${2}
LIBNAME=${3:-scopy}

handle_${OS_TYPE}
