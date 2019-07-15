#----------------------------------------------------------------------
# System
# 1. Base OS/Packages
#    Derived from CentOS7 base image for maximum compatibility across
#    potential systems (primarily for compatibility with CentOS6 kernel)
FROM falaise-centos7-base:latest
MAINTAINER Ben Morgan <Ben.Morgan@warwick.ac.uk>

# ARG for production/devel as well?
ARG HOMEBREW_USER=snemo
ARG HOMEBREW_PREFIX=/opt/supernemo

#----------------------------------------------------------------------
# 8. Entry/Cmd
USER $HOMEBREW_USER
RUN brew install falaise --cc=gcc-7 \
  && rm -rf "$(brew --cache)"
COPY --chown=snemo:snemo Docker/snemo-docker-entrypoint.bash $HOMEBREW_PREFIX/bin/snemo-docker-entrypoint.bash
ENTRYPOINT ["snemo-docker-entrypoint.bash"]
CMD ["snemo-docker-shell"]

