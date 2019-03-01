#----------------------------------------------------------------------
# System
# 1. Base OS/Packages
#    - We add a snemo user so we don't have to run brew as root
#    - For Singularity compatibility we don't use $HOME
#      or $TMP as Homebrew's PREFIX. As we build from source anyway this is
#      not a significant cost.
#    - Use ARGs so we can change it when building if required
FROM ubuntu:18.04
MAINTAINER Ben Morgan <Ben.Morgan@warwick.ac.uk>

ARG HOMEBREW_USER=snemo
ARG HOMEBREW_PREFIX=/opt/supernemo

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
     ca-certificates \
     curl \
     file \
     g++ \
     git \
     locales \
     make \
     uuid-runtime \
     # Graphics deps to build
     libx11-dev \
     libxpm-dev \
     libxft-dev \
     libxext-dev \
     libglu1-mesa-dev \
     flex \
     texinfo \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && localedef -i en_US -f UTF-8 en_US.UTF-8 \
	&& useradd -m -s /bin/bash $HOMEBREW_USER \
	&& echo '$HOMEBREW_USER ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers

# 2. Set up Homebrew in a given location
ENV PATH=${HOMEBREW_PREFIX}/bin:${HOMEBREW_PREFIX}/sbin:$PATH
RUN git clone https://github.com/SuperNEMO-DBD/brew.git ${HOMEBREW_PREFIX}/Homebrew \
  && cd ${HOMEBREW_PREFIX} \
  && mkdir -p bin etc include lib opt sbin share var/homebrew/linked Cellar \
  && ln -s ../Homebrew/bin/brew ${HOMEBREW_PREFIX}/bin/ \
  && chown -R $HOMEBREW_USER: ${HOMEBREW_PREFIX}

#----------------------------------------------------------------------
# Userspace
# 3. Switch to linuxbrew user for final setup
USER $HOMEBREW_USER
WORKDIR /home/$HOMEBREW_USER
ENV SHELL=/bin/bash \
  USER=$HOMEBREW_USER

# 4 Toolchain (Split in two for clarity)
RUN brew tap SuperNEMO-DBD/core \
  && brew install patchelf --cc=gcc-7 \
  && brew install flex --HEAD --cc=gcc-7 \
  && rm -rf "$(brew --cache)"
RUN brew install python --cc=gcc-7 \
  && brew install cmake --cc=gcc-7 \
  && brew install ninja --cc=gcc-7 \
  && rm -rf "$(brew --cache)"

# 5 Third Party Packages
RUN brew fetch -s $(brew deps -n --include-build bayeux | sed 's/flex//g') \
  && brew install $(brew deps -n --include-build bayeux | sed 's/flex//g') --cc=gcc-7 \
  && rm -rf "$(brew --cache)"

# 6 SuperNEMO Packages
RUN brew fetch -s bayeux \
  && brew install bayeux --cc=gcc-7 \
  && rm -rf "$(brew --cache)"

