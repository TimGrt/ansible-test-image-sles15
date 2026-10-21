ARG SLES_VERSION=15
ARG SLES_SERVICE_PACK=7

FROM registry.suse.com/bci/bci-init:${SLES_VERSION}.${SLES_SERVICE_PACK}

RUN zypper refresh && \
    zypper install -y \
      sudo \
      which \
      hostname \
      python3 \
      iproute2 && \
    zypper clean -a

RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/' /etc/sudoers

ENV ANSIBLE_USER=ansible

RUN set -xe \
    && useradd -m ${ANSIBLE_USER} \
    && echo "${ANSIBLE_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/ansible

VOLUME [ "/sys/fs/cgroup" ]
CMD [ "/usr/sbin/init" ]