#!/bin/sh -e

# This config script provides a method of adjusting the tarball
# contents immediately after the second stage install has completed.
# The script is copied into the tarball and unpacked to:
# $TARGET/machine/config.sh

# NOTE: At this stage, the ./debootstrap/ directory has already been
# removed. Do not rely on the tarball itself being available either.
# If any other files or scripts are needed by your additions to this
# script, you must ensure that setup.sh includes them into the tarball.

# It may be easier to create a normal Debian package that can do the
# job for you.

# This example file can act as a skeleton for your own scripts.
# Copy into $WORK/machine/$MACHINE/$VARIANT/ and edit.
# ($WORK is your emdebian working directory, as set in debconf.)
# Use 'default' as the variant directory if no other variants exist.
# config.sh does not have to be executable.
