#!/usr/bin/env bash

trap "kill 0" SIGINT

yell() { echo "$0: $*" >&2; }
die()  { yell "$*"; exit 111; }
try()  { "$@" || die "cannot $*"; }
run_cmd () {
    echo "> " $*
    eval $* || die "Fatal:  Command Failed"
}

BASE_DISTRO=$(buildah from alpine)

CMD="buildah config ${BASE_DISTRO}"
run_cmd ${CMD}

CMD="buildah run ${BASE_DISTRO} apk add --no-cache openssh-client git"
run_cmd ${CMD}

CMD="buildah run ${BASE_DISTRO} mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts"
run_cmd ${CMD}

CMD="buildah run --mount=type=ssh ${BASE_DISTRO} git clone git@github.com:cornelisnetworks/cnmu.git"
run_cmd ${CMD}


exit




CTR=$(buildah from ucbbar/chipyard-image)
cmd="buildah config $CTR"
run_cmd ${cmd}
cmd="buildah run $CTR /bin/sh -c 'dnf -y install \
     make                                        \
     autoconf                                    \
     automake                                    \
     libtool                                     \
     git                                         \
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
