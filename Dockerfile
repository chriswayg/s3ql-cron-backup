# docker run --cap-add mknod --cap-add sys_admin --device=/dev/fuse s3ql
## TODO: volume mounts that can be used by other containers

FROM alpine:latest
LABEL maintainer="Christian Wagner https://github.com/chriswayg"
ENV TERM="xterm"

ENV S3QL_CACHE_DIR="/root/.s3ql"
ENV S3QL_AUTHINFO_FILE="/root/.s3ql/authinfo2"
ENV S3QL_MOUNT_OPTIONS="--allow-other"
ENV S3QL_MOUNTPOINT="/mnt/s3ql"
ENV S3QL_PREFIX="default"

COPY s3ql /etc/init.d/s3ql

# Install dependencies.
RUN apk --no-cache add --update \
      openrc \
      busybox-initscripts \
      shadow \
      coreutils \
      util-linux \
      tar \
      psmisc \
      procps \
      openssl \
      rsync \
      python3 \
      fuse \
      sqlite-libs \
      build-base \
      python3-dev \
      attr-dev \
      fuse-dev \
      sqlite-dev \
 # Disable getty's
 && sed -i 's/^\(tty\d\:\:\)/#\1/g' /etc/inittab \
 && sed -i \
      # Change subsystem type to "docker"
      -e 's/#rc_sys=".*"/rc_sys="docker"/g' \
      # Allow all variables through
      -e 's/#rc_env_allow=".*"/rc_env_allow="\*"/g' \
      # Start crashed services
      -e 's/#rc_crashed_stop=.*/rc_crashed_stop=NO/g' \
      -e 's/#rc_crashed_start=.*/rc_crashed_start=YES/g' \
      # Define extra dependencies for services
      -e 's/#rc_provide=".*"/rc_provide="loopback net"/g' \
      /etc/rc.conf \
 # Remove unnecessary services
 && rm -vf \
      /etc/init.d/hwdrivers \
      /etc/init.d/hwclock \
      /etc/init.d/modules \
      /etc/init.d/modules-load \
      /etc/init.d/modloop \
 # Can't do cgroups
 && sed -i 's/cgroup_add_service /# cgroup_add_service /g' /lib/rc/sh/openrc-run.sh \
 #&& sed -i 's/VSERVER/DOCKER/Ig' /lib/rc/sh/init.sh \
 # Upgrade pip and install Python module dependencies
 && pip3 install --upgrade pip \
 && pip3 install pycrypto defusedxml requests apsw llfuse dugong setuptools pytest \
 && cd /tmp \
 # Determine latest version of s3ql and download source code
 && S3QL_VERSION=$(wget -q https://bitbucket.org/nikratio/s3ql/raw/default/Changes.txt -O - | grep -m1  "20" | sed 's/.*\([0-9].[0-9][0-9]\)/\1/') \
 && echo "*** Downloading S3QL Version: ${S3QL_VERSION}" \
 && wget -q https://bitbucket.org/nikratio/s3ql/downloads/s3ql-${S3QL_VERSION}.tar.bz2 \
 && tar jxf s3ql-${S3QL_VERSION}.tar.bz2 \
 && cd /tmp/s3ql-${S3QL_VERSION} \
 # Build and test s3ql
 && python3 setup.py build_ext --inplace \
 && mkdir -pv ~/.s3ql/ \
 && cd /tmp/s3ql-2.26 \
 # && python3 -m pytest -rs tests/ \
 # Install s3ql in /usr
 && python3 setup.py install \
 # Remove build related stuff
 && pip3 uninstall -y pytest \
 && apk del build-base python3-dev attr-dev fuse-dev sqlite-dev \
 && rm -r /tmp/s3ql-${S3QL_VERSION} \
 && echo -e "*** Installed \c" \
 && mount.s3ql --version \
 && rc-update add s3ql default

# Copy docker-entrypoint
COPY ./scripts/ /usr/local/bin/

# Persist data
#VOLUME /mnt/s3ql

ENTRYPOINT ["docker-entrypoint"]
CMD ["/sbin/init"]
