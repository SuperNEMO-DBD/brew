homebrew-snemo-sh() {
  # Avoid autoinstall of git on older platforms
  export HOMEBREW_NO_AUTO_UPDATE=1

  # 1. Get system/toolchain fingerprint
  osFingerprint=`uname -s`

  # Env always standard
  shArgs="--env=std"

  # 3. System specialization
  if [ $osFingerprint == "Linux" ]
  then
    # Linux is build from source
    export HOMEBREW_BUILD_FROM_SOURCE=1

    # Toolchain is gcc-7, env is std
    shArgs="--cc=gcc-7 $shArgs"
  fi

  # 3. Start brew shell with appropriate args
  brew sh $shArgs
}
