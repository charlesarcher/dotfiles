#!/usr/bin/env bash

trap "kill 0" SIGINT

yell() { echo "$0: $*" >&2; }
die()  { yell "$*"; exit 111; }
try()  { "$@" || die "cannot $*"; }
run_cmd () {
    echo "> " $*
    eval $* || die "Fatal:  Command Failed"
}

if [ $# -lt 2 ]
then
    echo "Error in $0 - Invalid Argument Count"
    echo "Syntax: $0 <gnu|intel|clang> <centos8|rhel7|ubuntu20.04>"
    exit
fi

DISTRO=$2
case $DISTRO in
    centos8 )
        echo "Building Images CentOS 8"
        DISTROSTR="docker.io/library/centos:8"
        ;;
    rhel7 )
        echo "Building Images RHEL7"
        DISTROSTR="registry.redhat.io/rhscl/devtoolset-10-toolchain-rhel7"
        ;;
    ubuntu18.04 )
        echo "Building Images for Ubuntu 18.04"
        DISTROSTR="docker.io/library/ubuntu:18.04"
        ;;
    ubuntu20.04 )
        echo "Building Images for Ubuntu 20.04"
        DISTROSTR="docker.io/library/ubuntu:20.04"
        ;;
    * )
        echo "Error:  Unknown compiler type"
        exit
esac

COMPILER=$1
case $COMPILER in
    intel )
        echo "Building Images for Intel Compiler"
        TOOLCHAIN=""
        case $DISTRO in
            centos8 )
                CTR=$(buildah from intel/oneapi-basekit:devel-centos8)
                ;;
            rhel7 )
                CTR=$(buildah from intel/oneapi-basekit:devel-centos8)
                ;;
            ubuntu20.04 )
                CTR=$(buildah from intel/oneapi:os-tools-ubuntu18.04)
                ;;
            * )
                echo "Error:  Intel cannot yet build with $DISTRO"
                exit
                ;;
        esac
        ;;
    gnu )
        echo "Building Images for GNU Compiler"
        TOOLCHAIN="gcc-toolset-9"
        CTR=$(buildah from ${DISTROSTR})
        ;;
    clang )
        echo "Building Images for Clang/LLVM Compiler"
        TOOLCHAIN="llvm-toolset"
        CTR=$(buildah from ${DISTROSTR})
        ;;
    * )
        echo "Error:  Unknown compiler type"
        exit
esac

cmd="buildah config $CTR"
run_cmd ${cmd}
cmd="buildah run $CTR /bin/sh -c 'dnf -y install \
     make                                        \
     autoconf                                    \
     automake                                    \
     libtool                                     \
     git                                         \
     file                                        \
     patch                                       \
     python3                                     \
     libuuid-devel                               \
     numactl-devel                               \
     glibc-langpack-en                           \
     perl-Time-HiRes                             \
     pandoc                                      \
     ${TOOLCHAIN}                                \
     containers-common;                          \
     dnf clean all'"
#dnf -y update; \
run_cmd ${cmd}

# Enable CentOS Powertools for flex and pandoc
cmd="buildah run $CTR /bin/sh -c 'dnf -y install dnf-plugins-core
     https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm'"
run_cmd ${cmd}

cmd="buildah run $CTR /bin/sh -c 'dnf config-manager --set-enabled powertools'"
run_cmd ${cmd}

cmd="buildah run $CTR /bin/sh -c 'dnf -y install pandoc flex-devel'"
run_cmd ${cmd}

cmd="buildah config --env _BUILDAH_STARTED_IN_USERNS=\"\" --env BUILDAH_ISOLATION=chroot $CTR"
run_cmd ${cmd}

cmd="buildah commit $CTR fabric_builder_${COMPILER}_${DISTRO}"
run_cmd ${cmd}
