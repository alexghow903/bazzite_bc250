# All credits go to Mothenjoyer69, Segfault, and Neggles.
# Thank Neggles for the script additions.

FROM ghcr.io/ublue-os/bazzite:stable

RUN --mount=type=cache,dst=/var/cache/rpm-ostree \
    echo -n "Adding mesa copr... " && \
    curl --output-dir "/etc/yum.repos.d/" --remote-name https://copr.fedorainfracloud.org/coprs/g/exotic-soc/bc250-mesa/repo/fedora-"${FEDORA_MAJOR_VERSION}"/group_exotic-soc-bc250-mesa-fedora-"${FEDORA_MAJOR_VERSION}".repo && \
    ostree container commit

RUN echo -n "Setting amdgpu module option... "  && \
    echo 'options amdgpu sg_display=0' > /etc/modprobe.d/options-amdgpu.conf && \
    echo -n "Setting nct6683 module option... " && \
    echo 'options nct6683 force=true' > /etc/modprobe.d/options-sensors.conf  && \
    ostree container commit

# install patched mesa + block any updates from main repos
RUN echo -n "Adding mesa copr... "  && \
    sed -i '2s/^/exclude=mesa*\n/' /etc/yum.repos.d/fedora.repo  && \
    sed -i '2s/^/exclude=mesa*\n/' /etc/yum.repos.d/fedora-updates.repo

# make sure radv_debug option is set in environment
RUN echo -n "Setting RADV_DEBUG option... "  && \
    echo 'RADV_DEBUG=nocompute' > /etc/environment

# install segfaults governor
# COPY /home/runner/rpmbuild/RPMS/x86_64/oberon-governor-1.0.0-1.x86_64.rpm /tmp/oberon-governor-1.0.0-1.x86_64.rpm
RUN echo "Installing GPU governor... " && \
    ostree container commit && \
    rpm-ostree install /oberon/oberon-governor-1.0.0-1.x86_64.rpm && \
    systemctl enable oberon-governor.service

RUN echo "Fixing up GRUB config..."  && \
#    sed -i 's/nomodeset//g' /etc/default/grub  && \
#    sed -i 's/amdgpu\.sg_display=0//g' /etc/default/grub  && \
#    grub2-mkconfig -o /etc/grub2.cfg  && \
    ostree container commit && \
    cat /etc/systemd/system/oberon-governor.service
