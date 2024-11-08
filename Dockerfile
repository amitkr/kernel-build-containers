ARG UBUNTU_VERSION
FROM ubuntu:${UBUNTU_VERSION} as base

ARG GCC_VERSION
ARG CLANG_VERSION
# needed in ubuntu to persist cache, otherwise the mount won't work!
RUN rm -f /etc/apt/apt.conf.d/docker-clean
RUN --mount=type=cache,mode=0755,target=/var/cache/apt \
    set -ex; \
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt-get update && \
    apt-get install -y -q apt-utils dialog && \
    apt-get install -y -q \
        aptitude bc bison bsdmainutils build-essential cpio dvipng dwarves \
        exuberant-ctags flex fonts-noto-cjk git graphviz imagemagick latexmk \
        libelf-dev libncurses5-dev libncurses-dev librsvg2-bin libssl-dev make \
        python3-sphinx python3-venv qemu-system-x86 sparse sudo \
        texlive-lang-chinese texlive-xetex vim-tiny xz-utils zstd \
        extlinux isolinux pxelinux syslinux syslinux-common syslinux-efi \
        syslinux-utils ovmf ovmf-ia32 python3-virt-firmware \
        sbuild-qemu imvirt virtme-ng u-boot-qemu  virt-top virtiofsd \
        genisoimage mkisofs \
        && \
    if [ "$GCC_VERSION" ]; then \
      apt-get install -y -q \
        gcc-${GCC_VERSION} g++-${GCC_VERSION} \
        gcc-${GCC_VERSION}-plugin-dev \
        gcc-${GCC_VERSION}-aarch64-linux-gnu \
        g++-${GCC_VERSION}-aarch64-linux-gnu \
        gcc-${GCC_VERSION}-arm-linux-gnueabi \
        g++-${GCC_VERSION}-arm-linux-gnueabi; \
      if [ "$GCC_VERSION" != "4.9" ]; then \
        apt-get install -y -q \
            gcc-${GCC_VERSION}-plugin-dev-aarch64-linux-gnu \
            gcc-${GCC_VERSION}-plugin-dev-arm-linux-gnueabi; \
      fi; \
      update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${GCC_VERSION} 100; \
      update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-${GCC_VERSION} 100; \
      update-alternatives --install /usr/bin/aarch64-linux-gnu-gcc aarch64-linux-gnu-gcc /usr/bin/aarch64-linux-gnu-gcc-${GCC_VERSION} 100; \
      update-alternatives --install /usr/bin/aarch64-linux-gnu-g++ aarch64-linux-gnu-g++ /usr/bin/aarch64-linux-gnu-g++-${GCC_VERSION} 100; \
      update-alternatives --install /usr/bin/arm-linux-gnueabi-gcc arm-linux-gnueabi-gcc /usr/bin/arm-linux-gnueabi-gcc-${GCC_VERSION} 100; \
      update-alternatives --install /usr/bin/arm-linux-gnueabi-g++ arm-linux-gnueabi-g++ /usr/bin/arm-linux-gnueabi-g++-${GCC_VERSION} 100; \
    fi; \
    if [ "$CLANG_VERSION" ]; then \
      apt-get install -y -q clang-${CLANG_VERSION} lld-${CLANG_VERSION} clang-tools-${CLANG_VERSION}; \
      update-alternatives --install /usr/bin/clang clang /usr/bin/clang-${CLANG_VERSION} 100; \
      update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-${CLANG_VERSION} 100; \
      update-alternatives --install /usr/bin/lld lld /usr/bin/lld-${CLANG_VERSION} 100; \
    fi; \
    rm -rf /var/lib/apt/lists/*

ARG UNAME
ARG UID
ARG GNAME
ARG GID
RUN set -x; \
    # These commands are allowed to fail (it happens for root, for example).
    # The result will be checked in the next RUN.
    userdel -r `getent passwd ${UID} | cut -d : -f 1` > /dev/null 2>&1; \
    groupdel -f `getent group ${GID} | cut -d : -f 1` > /dev/null 2>&1; \
    groupadd -g ${GID} ${GNAME}; \
    useradd -u $UID -g $GID -G sudo -ms /bin/bash ${UNAME}; \
    mkdir /src; \
    chown -R ${UNAME}:${GNAME} /src; \
    mkdir /out; \
    chown -R ${UNAME}:${GNAME} /out; \
    echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers; \
    echo "Set disable_coredump false" >> /etc/sudo.conf

USER ${UNAME}:${GNAME}
WORKDIR /src

RUN set -ex; \
    id | grep "uid=${UID}(${UNAME}) gid=${GID}(${GNAME})"; \
    sudo ls; \
    pwd | grep "^/src"; \
    touch /src/test; \
    rm /src/test; \
    touch /out/test; \
    rm /out/test

CMD ["bash"]
