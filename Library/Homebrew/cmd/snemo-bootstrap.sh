#:  * `snemo-bootstrap`:
#:    Bootstraps install of SuperNEMO toolchain and software

homebrew-snemo-bootstrap() {
  # Avoid autoinstall of git on older platforms
  export HOMEBREW_NO_AUTO_UPDATE=1

  # Get expected Brewfile dir
  readonly SNEMO_BREWFILE_DIR="$(brew --repo)/Brewfiles"

  # 1. Only allow running on an empty cellar as a toolchain change
  #    is only really sane from scratch
  installedFormulae=`brew ls`
  if [ ! "$installedFormulae" == "" ] ; then
    echo "warning: You already have Formulae installed, expect warnings or error during bootstrap" >&2
  fi

  # 2. Get system/toolchain fingerprint
  osFingerprint=`uname -s`
  toolchainFingerprint="system"

  # 3. System specialization
  if [ $osFingerprint == "Linux" ]
  then
    # Linux is build from source
    export HOMEBREW_BUILD_FROM_SOURCE=1

    # Use system compiler if it is 7 or better
    gccMajorVersion=`/usr/bin/gcc -dumpversion 2>/dev/null | cut -d. -f1`

    if (( gccMajorVersion < 7 ))
    then
      toolchainFingerprint="gcc7"
    fi

    # On Ubuntu 18, there is an issue with flex, so we require the HEAD
    # version
    isUbuntuBionic=$(cat /etc/os-release 2>/dev/null | grep -c "Ubuntu 18.04")
    if [[ ! "$isUbuntuBionic" == "0" ]]
    then
      toolchainFingerprint="ubuntu1804"
    fi

     # Could try and detect binutils/gcc compat here, or arch/native/binutils
     # mismatch...
  fi

  # 3. Try Brewfile for fingerprint
  #    We'll place Brewfiles under ourself...
  brew bundle install -v --file="$SNEMO_BREWFILE_DIR/$osFingerprint-$toolchainFingerprint.brewfile"
}
