#----------------------------------------------------------------------
# System
# 1. Base OS/Packages
#    - We add a snemo user so we don't have to run brew as root
#    - For Singularity compatibility we don't use $HOME
#      or $TMP as Homebrew's PREFIX. As we build from source anyway this is
#      not a significant cost.
#    - Use ARGs so we can change it when building if required
FROM centos:centos7
MAINTAINER Ben Morgan <Ben.Morgan@warwick.ac.uk>

ARG HOMEBREW_USER=snemo
ARG HOMEBREW_PREFIX=/opt/supernemo

# Can search for rpms providing files using "yum whatprovides",
# e.g. yum whatprovides "*/x11.pc"
RUN yum update -y \
  && yum install -y \
     curl \
     gcc \
     gcc-c++ \
     git \
     make \
     which \
  # Needed for ROOT, Qt5 and automake(!)
  && yum install -y \
     libX11-devel \
     libXext-devel \
     libXft-devel \
     libXpm-devel \
     mesa-libGL-devel \
     mesa-libGLU-devel \
     perl-Data-Dumper \
     perl-Thread-Queue \
  && yum clean all \
  && rm -rf /var/cache/yum \
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

# 4. Toolchain (Split in two for clarity)
RUN brew tap SuperNEMO-DBD/core \
  && brew install gcc@7 --without-glibc \
  && brew install patchelf --cc=gcc-7 \
  && rm -rf "$(brew --cache)"
RUN brew install python --cc=gcc-7 \
  && brew install cmake --cc=gcc-7 \
  && brew install ninja --cc=gcc-7 \
  && rm -rf "$(brew --cache)"

# 5. Third Party Packages
RUN brew fetch -s $(brew deps -n --include-build bayeux) \
  && brew install $(brew deps -n --include-build bayeux) --cc=gcc-7 \
  && rm -rf "$(brew --cache)"

# 6. SuperNEMO Core
RUN brew fetch -s bayeux falaise \
  && brew install bayeux falaise --cc=gcc-7 \
  && rm -rf "$(brew --cache)"

#----------------------------------------------------------------------
# Runtime
# 7. Data directories for Lyon, Warwick, ...
USER root
RUN mkdir /afs /pbs /sps \
  # Directories for Warwick
  && mkdir /storage

# 8. Entry/Cmd
USER $HOMEBREW_USER
COPY --chown=snemo:snemo Docker/snemo-docker-entrypoint.bash $HOMEBREW_PREFIX/bin/snemo-docker-entrypoint.bash
ENTRYPOINT ["snemo-docker-entrypoint.bash"]
CMD ["snemo-docker-shell"]

