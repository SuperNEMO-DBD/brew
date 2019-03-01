#!/bin/bash -e
#
# Copyright 2019 SuperNEMO Collaboration
# Copyright 2013-2019 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

# Provide an entrypoint for SuperNEMO's shell session
# - Interactive by default, erroring if the Container doesn't have an
#   interactive TTY
# - Run supplied command under session otherwise

set -x


if [ "$1" '=' 'snemo-docker-shell' ] ; then
    if [ -t 0 ] ; then
        exec brew snemo-shell
    else
        (
            echo "It looks like you're trying to run an interactive shell"
            echo "session, but either no pseudo-TTY is allocated for this"
            echo "container's STDIN, or it is closed."
            echo

            echo "Make sure you run docker with the --interactive and --tty"
            echo "options."
            echo
        ) >&2

        exit 1
    fi
else
    args="$@"
    exec brew snemo-shell -c "$args"
    exit $?
fi
