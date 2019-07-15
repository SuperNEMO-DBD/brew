# SuperNEMO-DBD Homebrew

Due to Homebrew's move to only supporting binary installs, removing options, and
not allowing core formulae to be overriden in pinned Taps, SuperNEMO is migrating
to use of the [Spack Package Manager](https://spack.io). To provide temporary support
during Spack testing, we have forked upstream Linuxbrew to enable restoration of
needed build-from-source and changes to core formulae for the SuperNEMO software.
The current C++/Python Toolchain comprises GCC 7 (Linux) or Apple LLVM (macOS),
Python 3.7, and all C++ binaries compiled against the ISO C++11 Standard. Data
persistency uses the ROOT 6 format.

The software may be installed either natively on Linux/macOS, or
as a Singularity/Docker Image on any platform supporting Singularity/Docker.
A native install simply means that everything is compiled and run directly
on your host OS just like all other software on the system. The image, paraphrasing from
[Docker](https://www.docker.com/resources/what-container) is *" a lightweight,
standalone, executable package that includes everything needed to run
or develop the SuperNEMO software: runtime, simulation, reconstruction, analysis, system tools and libraries, and settings"*.
Images are somewhat like a small Virtual Machine or Emulator, but practical
use is closer to running a shell/interpreter like `bash` or `Python`.

# Prerequisites
For both native and image installs, your system will require 4GB of disk
space, plus a working network connection during installation to download
sources and binaries. We recommend use of image installs on Linux
systems that supply and support Singularity, and native from-source
builds otherwise (for example on macOS laptops). Both provide an identical
set of software, but images are easier, faster, and more reliable to both
install and use.


## Native Install Prerequisites
The following Linux or macOS base systems are required
for native installs:

- CentOS/Scientific/RedHat Linux 7
  - At a terminal prompt, run (or ask your friendly neighbourhood sysadmin to run):

  ```
  $ sudo yum install curl gcc gcc-c++ git make which libX11-devel libXext-devel libXft-devel libXpm-devel mesa-libGL-devel mesa-libGLU-devel perl-Data-Dumper perl-Thread-Queue
  ```

  - *CentOS 8 support is expected once this reaches release*

- Ubuntu Linux 16.04LTS, 18.04LTS
  - At a terminal prompt, run (or ask your friendly neighbourhood sysadmin to run):

  ```
  $ sudo apt-get install ca-certificates curl file g++ git locales make uuid-runtime libx11-dev libxpm-dev libxft-dev libxext-dev libglu1-mesa-dev flex texinfo
  ```

- macOS Sierra, High Sierra, or Mojave
  - Install [Xcode](https://developer.apple.com/xcode/) from the [App Store](https://itunes.apple.com/gb/app/xcode/id497799835?mt=12).
  - *Catalina support is not expected until Q1 of 2020*


Linux distributions other than the above are not officially supported
or tested. Those derived from CentOS 7 or Ubuntu 18.04 (Debian buster/sid)
with the above package sets (or equivalent) should provide the necessary
base system.


## Image Install Prerequisites
To install images and run them in containers, either [Singularity](https://www.sylabs.io/singularity/)(Linux only)
or [Docker](https://www.docker.com)(Linux, macOS or Windows) is required.
For Docker on macOS or Windows, you will also require an X11 server if
a graphical interface is needed, or if you are connecting to CC IN2P3.
[XQuartz](https://www.xquartz.org) works well on macOS. There are no
recommendations for Windows yet, but you may try [PuTTY](https://www.chiark.greenend.org.uk/~sgtatham/putty/) as an SSH client
with [VcXsrv](https://sourceforge.net/projects/vcxsrv/) as the X11 server
(see also [this guide from UW-Madison](https://comphelp.chem.wisc.edu/content/installing-vcxsrv-and-putty)).

If you are using a centrally managed Linux system, you may have Singularity
installed already (for example, **it is available on SuperNEMO's Tier 1 at CC-IN2P3**).
Simply run

```
$ singularity --version
2.6.1-dist
```

to see if it is available. Otherwise, installation instructions are available
from the [Singularity Documentation](https://www.sylabs.io/guides/2.6/user-guide/index.html)
(note that this *does* require `root/sudo` privileges, so speak to your
friendly neighbourhood sysadmin if that isn't you).

For Docker, you can similarly check availability on your system using

```
$ docker --version
```

Docker is less likely to be present on centrally managed systems as
it requires higher permissions than Singularity. For self-managed machines,
it can be installed following the [Docker CE Guide for your platform](https://docs.docker.com/install/).
Though Docker is available on Linux, we recommend the use of Singularity
on this Platform.


# Quickstart
## Installing Natively From Scratch
If you do not have an existing install of the SuperNEMO software, then start by doing:

```
$ git clone https://github.com/SuperNEMO-DBD/brew.git snemo-sdk
$ eval $(./snemo-sdk/bin/brew shellenv)
$ brew snemo-doctor
```
It is likely that you will see some warnings from `brew snemo-doctor`. Unless this fails with
hard errors about missing system packages, you should proceed to the next step:

```
$ brew snemo-bootstrap
```

This step will take some time to complete as a full suite of development
tools and packages will be built from scratch. If you encounter
any errors here, you can run the command again in the case of it failing to
download packages, otherwise always [raise an Issue](https://github.com/SuperNEMO-DBD/brew/issues/new)
and **supply the requested information**.

Once installation is complete, test the top level `falaise` package:

```
$ brew test falaise
Testing falaise
==> <SOMEPATH>/Cellar/falaise/3.3.0/bin/flsimulate -o test.brio
==> <SOMEPATH>/Cellar/falaise/3.3.0/bin/flreconstruct -i test.brio -p urn:snemo:demonstrator:reconstruction:1.0.0 -o test.root
```

This should run successfully without any error, though some warnings may be expected on Linux.
If an error does occur, please [raise an Issue](https://github.com/SuperNEMO-DBD/brew/issues/new).

## Installing Images
Using Singularity:

```
$ singularity pull docker://supernemo/falaise
WARNING: pull for Docker Hub is not guaranteed to produce the
WARNING: same image on repeated pull. Use Singularity Registry
WARNING: (shub://) to pull exactly equivalent images.
Docker image path: index.docker.io/supernemo/falaise:latest
...
WARNING: Building container as an unprivileged user. If you run this container as root
WARNING: it may be missing some functionality.
Building Singularity image...
Singularity container built: ./falaise.simg
Cleaning up...
Done. Container is at: ./falaise.simg
$ ls
falaise.simg
```

The resultant `falaise.simg` image file contains everything you need to
run the offline software, and can be stored anywhere on your system. In the following, we assume
it is located in the current working directory, but if not simply supply
the full path to the image file. To cross check the image is o.k. and
your local Singularity setup, run

```
$ singularity exec falaise.simg brew test falaise
```

If you are at CC-IN2P3 (Lyon), you will need to run this as

```
$ singularity exec --home $HOME falaise.simg brew test falaise
error: could not lock config file /opt/supernemo/Homebrew/.git/config: Read-only file system
Testing falaise
==> /opt/supernemo/Cellar/falaise/3.3.0/bin/flsimulate -o test.brio
==> /opt/supernemo/Cellar/falaise/3.3.0/bin/flreconstruct -i test.brio -p urn:snemo:demonstrator:reconstruction:1.0.0 -o test.root
```

The exact output you see will depend on the local Singularity configuration
and the current production release. As long as you see the last three lines
and no subsequent errors, things should be o.k. By default, Singularity pulls the `latest`
image tag, which always contains the current production release.


Using Docker:

```
$ docker pull supernemo/falaise
latest: Pulling from supernemo/falaise
...
Digest: sha256:cf39166b250e91becf7a0bfcaa1c28152a07afddd8acf788e7d3289f6b5544aa
Status: Downloaded newer image for supernemo/falaise:latest
```

Docker will manage the image files for you, and their state can
be checked at any time by running

```
$ docker images
```

As with Singularity, the `falaise` package should be tested:

```
$ docker run --rm supernemo/falaise brew test falaise
Testing falaise
==> /opt/supernemo/Cellar/falaise/3.3.0/bin/flsimulate -o test.brio
==> /opt/supernemo/Cellar/falaise/3.3.0/bin/flreconstruct -i test.brio -p urn:snemo:demonstrator:reconstruction:1.0.0 -o test.root
$
```

The value you see for the `sha256` digest when pulling and the versions on the test
output will depend on the current production release. As with Singularity the `pull`
command downloads the default `latest` tag which always points to the current production release.


# Using the SuperNEMO Software Environment
For both native and image installs, the primary way to use the SuperNEMO
software is to start a shell session which configures access to the
applications and all the tools needed to run or develop them.

We defer instructions on the use and development of the applications *themselves*
to those on [the main project page](https://github.com/supernemo-dbd/Falaise).
Here we simply demonstrate how to start up the interactive shell session.

## Using a Native Install
With native installs, a new shell session configured with the applications
and needed development tools is started using the `snemo-shell` subcommand
of `brew`:

```
$ $HOME/snemo-sdk/bin/brew snemo-shell
Homebrew >=1.7.1 (shallow or no git repository)
Supernemo-dbd/homebrew-core (git revision 15b2f; last commit 2019-02-27)
Type "brew ls --versions" to list available software
Type "exit" to deactivate the session
snemo-shell> flsimulate --help
...
```

Use `exit` to close the session and return to a standard environment.
Whilst `snemo-shell` makes every effort to sanitize the environment, you
may have issues if you either start it from an already complex setup,
or if you further modify environment variables whilst in the shell.
It's recommended to add an alias in your shell's configuration file to
simplify starting up the shell session, for example

``` bash
alias snemo-session="$HOME/snemo-sdk/bin/brew snemo-shell"
```

You can also run commands through `snemo-shell` without interaction using
the `-c <command>` form:

```
$ brew snemo-shell -c "flsimulate --version"
...
```

The argument to `-c` must be given as a quoted string to handle arguments
and variables correctly, and the command(s) must be present on the `PATH`.

## Using an Image
Images may be used in a similar way, but we start the `brew snemo-shell` session
inside a "container" running the image. For Singularity, we use the [`exec` subcommand](https://www.sylabs.io/guides/2.6/user-guide/appendix.html#exec)
to start the container and run the `brew snemo-shell` session in it:

```
$ singularity exec falaise.simg brew snemo-shell
Homebrew >=1.7.1 (shallow or no git repository)
Supernemo-dbd/homebrew-core (git revision 15b2f; last commit 2019-02-27)
Type "brew ls --versions" to list available software
Type "exit" to deactivate the session
snemo-shell> flsimulate --help
...
snemo-shell> exit
$
```

Be extremely careful if you have highly custom or complex environment settings, as these will be exported into the running
container and may result in errors (for example, you refer to a path which does
not exist in the image).

Whilst the exact behaviour inside the Container will depend on how your Singularity
install has been set up, you will generally have at least full read-write access to files
on your `$HOME` and `$TMP` areas on the machine running Singularity, and be able
to start graphical programs like ROOT and `flvisualize`. **A notable exception here
is the CC-IN2P3 Tier 1 center, where you will need to run Singularity with additional
arguments**:

```
ccin2p3> singularity exec --home $HOME --bind /sps falaise.simg brew snemo-shell
```

These mount your `$HOME` area and the `/sps/` data directory in the running container.

As with native installs, you may wish to add `aliases` to simplify running, e.g.

``` bash
alias snemo-session="singularity exec --home $HOME --bind /sps <PATHTO>/falaise.simg brew snemo-shell"
```

Programs can be executed non-interactively in a container using the [`run`
subcommand](https://www.sylabs.io/guides/2.6/user-guide/appendix.html#run),
e.g.

```
$ singularity run falaise.simg flsimulate --help
...
```

As with the `exec` command, you will need to use the `--home $HOME --bind /sps` arguments
at CC-IN2P3 to share the `/sps` data directory and your `$HOME` area with the container.
These, together with `run`, enable you to run both general and production processing, reconstruction,
and analysis tasks at CC-IN2P3, including batch jobs. Please see their dedicated [Singularity @ CC-IN2P3 documentation](https://doc.cc.in2p3.fr/logiciels:singularity)([or in English](https://doc.cc.in2p3.fr/en:logiciels:singularity)) for further instructions. It is also possible to run graphical programs such as `root` or `flvisualize`
in the image. 

Much more is possible with Singularity, with a very clear and detailed
overview available in its [online documentation](https://www.sylabs.io/guides/2.6/user-guide/index.html).

Docker images can be run either interactively:

```
$ docker run --rm -it supernemo/falaise
Homebrew >=1.7.1 (shallow or no git repository)
Supernemo-dbd/homebrew-core (git revision 15b2f; last commit 2019-02-27)
Type "brew ls --versions" to list available software
Type "exit" to deactivate the session
snemo-shell>
...
snemo-shell> flsimulate --help
...
snemo-shell> exit
$
```

or just to execute a command:

```
$ docker run --rm supernemo/falaise flsimulate --help
...
```

The most important distinction from Singularity is that you
**do not** have access to your `$HOME` area, other filesystems, or
graphical connections inside the running container. Various ways are available to share
data between the host system and container, and we defer to
the [Docker documentation on this subject](https://docs.docker.com/storage/).

## Using Graphical Programs over a Remote Connections with X11 Forwarding

If you want to run graphical applications (or that may create graphics) such 
as `ROOT`, `flsimulate-configure`, or `python` over an SSH connection, some
additional steps are needed (and applies whether you run a Native or Image install on the
remote side). If you are connecting from a macOS or Windows host, then you will
need to have [XQuartz](https://www.xquartz.org) installed on macOS, or
[PuTTY](https://www.chiark.greenend.org.uk/~sgtatham/putty/) and [VcXsrv](https://sourceforge.net/projects/vcxsrv/)
on Windows (but note that PuTTY+VcXsrv are currently untested).

The minimum requirement is to use X11 forwarding when you start
the `ssh` connection, for example

```
$ ssh -X yourusername@theremote.host
```

In some cases, such as for CC-IN2P3, you may need to use trusted X11 forwarding:

```
$ ssh -Y yourusername@theremote.host
```

In both cases, you can check that graphics are working by running the `xeyes` program
after connecting, e.g.

```
$ ssh -X yourusername@theremote.host
...
theremote.host> xeyes
```

A little Xwindow with eyes that follow your mouse should pop up! If so, all graphical
programs in either a Native or (Singularity) Image install should work without issue.

Please note that the speed of getting and updating windows is dependent on the quality
of your network connection to the remote side. Most institute networks and even higher end
consumer broadband should support most tasks. If you do see significant slowness, you can
try enabling compression on the connection using the `-C` flag, e.g.

```
$ ssh -X -C yourusername@theremote.host
...
theremote.host> xeyes
```

See the `ssh` manual for more information on X11 forwarding and compression.


# Installing Additional Packages
If your work requires software packages not present in the installation,
you can install them through `brew` **if** Formulae for them exist. **Note
that at present this functionality is only supported for native installs because
Singularity only allows read-only access to the install area**.
Use the `search` subcommand to see if the package is available:

```
$ brew search <string>
```

If no results are returned, you can request it to be added
[through an Issue](https://github.com/SuperNEMO-DBD/brew/issues/new).

If the package you need is Python-based and available through PyPi, then you
must install it using `virtualenv` and `pip` supplied with the brewed
Python. Note here that `virtualenv` **can** be used inside a container.

In both cases, please keep your Working Group Coordinators informed so
that dependencies and requirements for deployment can be tracked. Failure
to do so will result in delays in your work being integrated into the
production releases.


# Keeping the SuperNEMO Software Updated
All offline software packages are installed using the current release
versions approved for production work. These must be used for all simulation,
processing, and analysis production tasks. Thus you should in general
**only update when a new release is announced**.

For native installs, updating the software is done with the `snemo-update`
command

```console
$ brew snemo-update
```

This will update the Homebrew installation itself, and then upgrade
any packages for new versions are available.

For images, simply follow the same procedure as documented for
installation. For Singularity, you can either overwrite your existing
image file or create a new one.


# SuperNEMO Extension Commands for `brew`
The following subcommands for `brew` are available for SuperNEMO specific
tasks.

## `snemo-doctor`
Runs a series of checks on the system and installation, warning if anything
may cause issues with installing or using packages.

## `snemo-shell`
Starts a new shell session in which the environment is configured for
using and developing the SuperNEMO software. It can also be used to
run commands non-interactively. See `brew help snemo-shell` for additional
information on thisbe used to
run commands non-interactively. See `brew help snemo-shell` for additional
information on this..

## `snemo-bootstrap`
Installs the software stack from scratch into a clean Homebrew install.
It may fail if any Formulae are already installed as it cannot guarantee a
clean build otherwise.

## `snemo-update`
Updates Homebrew code and Formula definitions before upgrading any outdated
packages to latest stable versions.

## `snemo-formula-history`
SuperNEMO-supplied implementation of the old `versions` subcommand.
It is retained to help in preparing versioned snapshots.

```sh
$ brew snemo-formula-history cmake
cmake 3.13.3   8835fde8b77 homebrew/core Formula/cmake.rb
cmake 3.13.2   a712c28df66 homebrew/core Formula/cmake.rb
...
```

Each output line shows the formula name, version (including any revisions),
last commit to touch the formula at this version, the Tap hosting the Formula,
and the path to the Formula relative to the Tap root.

A complete history of the version/commits touching the formula may be
viewed by passing the `--all` argument. This can be useful for resolving
potential conflicts caused by version reverts or merges from Homebrew to
Linuxbrew as the merge commit may not show as the one where the version changed.


