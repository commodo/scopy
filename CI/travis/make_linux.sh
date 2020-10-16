#!/bin/bash
set -e

. CI/travis/lib.sh

handle_default() {
	mkdir -p build
	pushd build
	cmake ..
	make -j${NUM_JOBS}
}

handle_centos() {
	export PATH=/usr/lib64:/usr/local/lib/pkgconfig:$PATH
	export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig

	handle_default
}

handle_centos_docker() {
	run_docker_script inside_docker.sh \
		"centos:centos${OS_VERSION}" "centos"
}

handle_ubuntu_docker() {
	run_docker_script inside_docker.sh \
		"ubuntu:${OS_VERSION}"
}

handle_ubuntu_flatpak_docker() {
	sudo docker run --privileged --rm=true \
			-v `pwd`:/scopy:rw \
			alexandratr/ubuntu-flatpak-kde:latest \
			/bin/bash -xe /scopy/CI/travis/inside_ubuntu_flatpak_docker.sh
}

LIBNAME=${1:-scopy}
OS_TYPE=${2:-default}

handle_${OS_TYPE}

