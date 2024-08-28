ARG BASE_OS_VERSION
ARG COMMON_BASE_OS_URL=armdocker.rnd.ericsson.se/proj-ldc/common_base_os_release/sles
FROM $COMMON_BASE_OS_URL:$BASE_OS_VERSION

ARG BASE_OS_VERSION

RUN zypper addrepo -C -G -f https://arm.sero.gic.ericsson.se/artifactory/proj-ldc-repo-rpm-local/common_base_os/sles/$BASE_OS_VERSION?ssl_verify=no COMMON_BASE_OS_SLES_REPO \
    && zypper install -l -y curl \
    && zypper clean --all

# ADD docker/tzdata.tar.gz /usr/share

# ARG USER_ID=49527
# ARG USER_NAME="eric-ref-catfacts-text-analyzer"
# RUN echo "$USER_ID:x:$USER_ID:0:An Identity for $USER_NAME:/nonexistent:/bin/false" >>/etc/passwd
# RUN echo "$USER_ID:!::0:::::" >>/etc/shadow
# USER $USER_ID

CMD ["/usr/bin/sleep","2"]