#!/bin/bash
##
## reference: http://askubuntu.com/questions/428698/chromebook-with-crouton-alternative-repository-to-ports-ubuntu-com
## required: curl

if [ $# -ne 3 ];then
	cat << EOF
Usage: $0 <ARCH> <DIST> <REPO>
example: $0 armhf trusty main
EOF
	exit 0
fi

# URL of the Launchpad mirror list
MIRROR_LIST=https://launchpad.net/ubuntu/+archivemirrors

# Set to the architecture you're looking for (e.g., amd64, i386, arm64, armhf, armel, powerpc, ...).
# See https://wiki.ubuntu.com/UbuntuDevelopment/PackageArchive#Architectures
ARCH=$1
# Set to the Ubuntu distribution you need (e.g., precise, saucy, trusty, ...)
# See https://wiki.ubuntu.com/DevelopmentCodeNames
DIST=$2
# Set to the repository you're looking for (main, restricted, universe, multiverse)
# See https://help.ubuntu.com/community/Repositories/Ubuntu
REPO=$3

arr={}
count=0
# First, we retrieve the Launchpad mirror list, and massage it to obtain a newline-separated list of HTTP mirrors
for url in $(curl -k $MIRROR_LIST | grep 'http</a>' | sed -e 's/.*"\(http:\/\/.*\)">.*/\1/;'); do
  # If you like some output while the script is running (feel free to comment out the following line)
  echo "Processing $url..."
  # retrieve the header for the URL $url/dists/$DIST/$REPO/binary-$ARCH/; check if status code is of the form 2.. or 3..
  curl -s --head $url/dists/$DIST/$REPO/binary-$ARCH/ | head -n 1 | grep "HTTP/1.[01] [23].." > /dev/null
  # if successful, output the URL
  if [ $? -eq "0" ]; then
    echo "FOUND: $url"
    arr[$((count++))]="$url/dists/$DIST/$REPO/binary-$ARCH/"
  fi
done

echo === result ===
for r in ${arr[@]};do
  echo $r
done
