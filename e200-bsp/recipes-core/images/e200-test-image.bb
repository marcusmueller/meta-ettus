DESCRIPTION = "A console-only image with more full-featured Linux system \
functionality installed."

IMAGE_FEATURES += "splash ssh-server-openssh tools-sdk \
                   tools-debug debug-tweaks"

EXTRA_IMAGE_FEATURES += "package-management"

IMAGE_INSTALL = "\
    packagegroup-core-boot \
    packagegroup-core-basic \
    tools-debug \
    i2c-tools \
    screen \
    vim \
    vim-vimrc \
    git \
    boost-dev \
    cmake \
    python \
    python-cheetah \
    python-modules \
    python-argparse \
    htop \
    sshfs-fuse \
    glib-2.0-dev \
    orc-dev \
    "

inherit core-image
