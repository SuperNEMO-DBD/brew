#:  * `snemo` [`--exec=`<command>]
#:    Start an interactive SuperNEMO build/runtime shell.
#:
#:    Configures and starts a shell environment with paths and variables
#:    for running the SuperNEMO software. Compiler, CMake and Pkg-Config
#:    paths and flags are also set to enable development of the SuperNEMO
#:    software in a reliable and isolated environment.
#:
#:    If `--exec=`<command> is passed, run <command> in the environment
#:    instead of an interactive shell. <command> must be given as a quoted
#:    string, and must be an executable present in the PATH. Additional
#:    arguments to <command> can be specified, e.g.
#:
#:        brew snemo-shell --exec='ls -l'
#:

require "extend/ENV"
require "cli_parser"
require "formula"

module Homebrew
  module_function

  def snemo_shell_args
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS
        `snemo-shell` [`--exec=`<command>]

        Start an interactive SuperNEMO build/runtime shell.

        Configures and starts a shell environment with paths and variables
        for running the SuperNEMO software. Compiler, CMake and Pkg-Config
        paths and flags are also set to enable development of the SuperNEMO
        software in a reliable and isolated environment.

        If `--exec=`<command> is passed, run <command> in the environment
        instead of an interactive shell. <command> must be given as a quoted
        string, and must be an executable present in the PATH. Additional
        arguments to <command> can be specified, e.g.

          brew snemo-shell --exec='ls -l'
      EOS
      flag "-c=", "--exec=",
        description: "Run the given command in the SuperNEMO shell and exit"
      switch :debug
    end
  end

  def snemo_shell
    snemo_shell_args.parse

    # Always env=std, plus gcc-7 on linux
    ARGV.delete_if {|arg| arg.start_with?("--cc", "--env")}
    ARGV << "--env=std"
    ARGV << "--cc=gcc-7" unless OS.mac?

    # Should setup basic stdenv
    ENV.activate_extensions!

    # Now build settings
    ENV.setup_build_environment
    ENV["VERBOSE"] = "1"
    ENV.cxx11
    # Filter out -w from flags so users can get build warnings as normal
    ENV["CFLAGS"] = ENV["CFLAGS"].gsub(/ \-w /,' ')
    ENV["CXXFLAGS"] = ENV["CXXFLAGS"].gsub(/ \-w /,' ')
    ENV["OBJCFLAGS"] = ENV["OBJCFLAGS"].gsub(/ \-w /,' ')
    ENV["OBJCXXFLAGS"] = ENV["OBJCXXFLAGS"].gsub(/ \-w /,' ')

    # List on installed keg_only deps
    deps = Formula.installed.select { |f| f.keg_only? && f.opt_prefix.directory? }

    # Various PATHs...
    # Even in std, want Homebrew's keg_only and main path before enythign else
    snemoPath = PATH.new(ENV["PATH"])
    snemoPath.prepend(deps.map(&:opt_bin))
    # Workaround for python3 names
    snemoPath.prepend(Formula["python"].libexec/"bin") if Formula["python"].installed?
    snemoPath.prepend(HOMEBREW_PREFIX/"bin")
    ENV["PATH"] = snemoPath

    # CMake/PkgConfig Paths extended with keg_onlys
    snemoCMakePath = PATH.new(ENV["CMAKE_PREFIX_PATH"])
    snemoCMakePath.prepend(deps.map(&:opt_prefix))
    ENV["CMAKE_PREFIX_PATH"] = snemoCMakePath

    snemoPkgConfigPath = PATH.new(ENV["PKG_CONFIG_PATH"])
    snemoPkgConfigPath.prepend(
      deps.map { |d| d.opt_lib/"pkgconfig" },
      deps.map { |d| d.opt_share/"pkgconfig" }
    )
    ENV["PKG_CONFIG_PATH"] = snemoPkgConfigPath

    # ROOT's python and include path if root6 installed
    ENV.prepend_path "PYTHONPATH", Formula["root6"].lib/"root" if Formula["root6"].installed?
    ENV.prepend_path "ROOT_INCLUDE_PATH", HOMEBREW_PREFIX/"include" if Formula["root6"].installed?

    # Bayeux doesn't declare full include paths, so ensure the top level
    # dir is also visible to root
    ENV.prepend_path "ROOT_INCLUDE_PATH", HOMEBREW_PREFIX/"include/bayeux" if Formula["bayeux"].installed?

    # Restore Graphical settings
    # DISPLAY is DISPLAY, wherever we are
    ENV["DISPLAY"] = ENV["HOMEBREW_DISPLAY"] if ENV["HOMEBREW_DISPLAY"]
    # In Singularity, we don't set XDG_RUNTIME_DIR, and override QT_XKB_CONFIG_ROOT
    # Otherwise forward on XDG_RUNTIME_DIR
    if OS.linux? and File.exist?("/singularity")
      ENV["XDG_RUNTIME_DIR"] = nil
      ENV["QT_XKB_CONFIG_ROOT"] = "/usr/share/X11/xkb"
    else
      ENV["XDG_RUNTIME_DIR"] = ENV["HOMEBREW_XDG_RUNTIME_DIR"] if ENV["HOMEBREW_XDG_RUNTIME_DIR"]
    end

    # Run needed command in bash
    shellCmd = %W[
      /bin/bash
      --rcfile #{HOMEBREW_REPOSITORY}/.snemo/bashrc
    ]
    shellCmd << "-c" << "#{args.exec}" if args.exec
    exec *shellCmd
  end
end
