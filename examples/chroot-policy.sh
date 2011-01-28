#!/bin/sh

set -e

# The script is called with the following arguments:

# $1 = $DIR  - the top directory of the debootstrapped system
# $2 = $ARCH - the specified architecture, already checked with dpkg-architecture.

# setup.sh needs to be executable.
if [ -d $1 ]; then
mkdir -p $1/usr/sbin/
cat > $1/usr/sbin/policy-rc.d << EOF
#!/bin/sh
echo "All runlevel operations denied by policy" >&2
EOF
chmod a+x $1/usr/sbin/policy-rc.d
fi
