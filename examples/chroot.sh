#!/bin/sh

set -e

# This setup script is an alternative method of adjusting the tarball
# contents immediately after multistrap has unpacked the packages.

# At this stage, any operations inside the rootfs must not try to
# execute any binaries within the rootfs.

# The script is called with the following arguments:

# $1 = $DIR  - the top directory of the debootstrapped system
# $2 = $ARCH - the specified architecture, already checked with dpkg-architecture.

# setup.sh needs to be executable.

TARGET=$1

if [ -x "$TARGET/sbin/initctl" ]; then
  mv "$TARGET/sbin/start-stop-daemon" "$TARGET/sbin/start-stop-daemon.REAL"
  echo \
"#!/bin/sh
echo
echo echo \"Warning: Fake start-stop-daemon called, doing nothing\"" > "$TARGET/sbin/start-stop-daemon"
  chmod 755 "$TARGET/sbin/start-stop-daemon"
fi
            
if [ -x "$TARGET/sbin/initctl" ]; then
    mv "$TARGET/sbin/initctl" "$TARGET/sbin/initctl.REAL"
    echo \
"#!/bin/sh
echo
echo \"Warning: Fake initctl called, doing nothing\"" > "$TARGET/sbin/initctl"
  chmod 755 "$TARGET/sbin/initctl"
fi
	  