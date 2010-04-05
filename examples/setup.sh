#!/bin/sh -e

# This setup script is an alternative method of adjusting the tarball
# contents immediately after the first stage install has completed.
# It may be easier to create a normal Debian package that can do the
# job for you. (Remember to use the postinst if you want to append
# to existing files instead of replacing the emsandbox versions.

# The script is called by embootstrap with the following arguments:

# $1 = $BUILDPLACE - the top directory of the debootstrapped system
# $2 = $ARCH - the specified architecture, already checked with dpkg-architecture.

# This example file can act as a skeleton for your own scripts.
# Copy into $WORK/machine/$MACHINE/$VARIANT/ and edit.
# ($WORK is your emdebian working directory, as set in debconf.)
# Use 'default' as the variant directory if no other variants exist.
# setup.sh does not have to be executable.

# Use any other scripts or files that you need for first stage install.
# To use any of those scripts or files in the second stage, ensure
# that this script copies the relevant files into the tarball at
# /machine/$MACHINE/$VARIANT/

# e.g. To pass the location of a kernel or other files to be added to the
# tarball, write out a file into $WORK/machine/$MACHINE/$VARIANT and
# read the contents into this script.

# Nothing to do by default.
