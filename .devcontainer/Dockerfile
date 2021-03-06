# Use latest debian buildpack as base devcontainer image
FROM buildpack-deps:buster

# Avoid container build to stuck on warning with noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN  apt-get update \
  && apt-get install --no-install-recommends -y apt-utils 2>&1 \
  # Check that git, procps and ssh are installed
  && apt-get install -y git procps ssh \
  # Firefox for karma test runner
  && apt-get install -y firefox-esr \
  # Google chrome for karma test runner
  && curl -L -o /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
  && dpkg -i /tmp/chrome.deb; apt-get -fy install \
  && rm -rf /tmp/chrome.deb \
  # Cleanup
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

# Install Node.js 12.13

ENV NODE_VERSION 12.13.1

RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" \
  && case "${dpkgArch##*-}" in \
    amd64) ARCH='x64';; \
    ppc64el) ARCH='ppc64le';; \
    s390x) ARCH='s390x';; \
    arm64) ARCH='arm64';; \
    armhf) ARCH='armv7l';; \
    i386) ARCH='x86';; \
    *) echo "unsupported architecture"; exit 1 ;; \
  esac \
  # gpg keys listed at https://github.com/nodejs/node#release-keys
  && set -ex \
  && for key in \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    77984A986EBC2AA786BC0F66B01FBB92821C587A \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
    4ED778F539E3634C779C87C6D7062848A1AB005C \
    A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
    B9E2F5981AA6E0CD28160D9FF13993A75599653C \
  ; do \
    gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
    gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
  done \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-$ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
  && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs

# Copy post create command
COPY ./post-create.sh /usr/local/bin/post-create.sh

# Create non-root development user and required directories

# User args, override these from docker-compose.yml
ARG USERNAME=developer
ARG GROUPNAME=developer
ARG UID=1000
ARG GID=1000

# Create group
RUN groupadd --gid $GID $GROUPNAME \
  # Create user
  && useradd --uid $UID --gid $GROUPNAME -m -s /bin/bash -d /server $USERNAME \
  # Create node_modules directory
  && mkdir -p /workspace/node_modules \
  # Create vscode-server install directory
  && mkdir -p /server/.vscode-server \
  # Set correct directory ownerships
  && chown -R $UID:$GID /workspace \
  && chown -R $UID:$GID /server/.vscode-server

# Expose common development ports
# HTTP, 3000, Livereload, Karma
EXPOSE 80 3000 35729 9876

# Set workdir
WORKDIR /workspace

# Set user
USER $USERNAME

# Set frontend back to interactive
ENV DEBIAN_FRONTEND=dialog
