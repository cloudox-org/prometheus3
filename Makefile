.PHONY: all build clean

VERSION ?= 10
PACKAGE = prometheus3
REGISTRY = ghcr.io/cloudox-org/cloudox-rpm-builder-alma
IMAGE = ${REGISTRY}:${VERSION}
OUT_DIR = el${VERSION}

all:
	$(MAKE) build VERSION=8
	$(MAKE) build VERSION=9
	$(MAKE) build VERSION=10

build:
	mkdir -p ${OUT_DIR}

	podman run --rm -v ${PWD}:/root/rpmbuild/SOURCES:z \
		-v ${PWD}/${OUT_DIR}:/root/rpmbuild/RPMS/x86_64:z \
		-v ${PWD}/${OUT_DIR}:/root/rpmbuild/RPMS/noarch:z \
		-v ${HOME}/.gnupg:/root/.gnupg:z \
		${IMAGE} \
		build-spec /root/rpmbuild/SOURCES/${PACKAGE}.spec

	podman run --rm -v ${PWD}/${OUT_DIR}:/var/tmp/:z \
		${IMAGE} \
		/bin/bash -c '/usr/bin/dnf install --verbose -y  /var/tmp/${PACKAGE}*.rpm'

	@echo "[*] Removing sources..."
	@rm -f *.tar.gz

clean:
	@echo "[*] Cleaning up build artifacts..."
	@rm -rf el8 el9 el10
	@rm -f *.tar.gz
	eecho "[*] Cleanup complete."
