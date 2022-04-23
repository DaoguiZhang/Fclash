#!/bin/bash

version_pattern="[0-9].[0-9].[0-9][-]*[0-9]*"

function change_deb_version() {
  sed -i "s/Version:\s*${version_pattern}/Version: $1/" debian/build-src/DEBIAN/control
  sed -i "s/\"version\":\s*\"${version_pattern}\"/\"version\": \"$1\"/" debian/build-src/opt/apps/cn.kingtous.fclash/info
}

# "version:".trParams({"version": '1.2.1-1'}),
function change_about_version() {
  sed -i "s/\"version\":\s*'${version_pattern}'/\"version\": '$1'/" lib/screen/page/about.dart
}

#
function change_arch() {
  echo "please change arch version manually for now."
}

# version: '1.2.1'
function change_snap() {
  sed -i "s/version:\s*'${version_pattern}'/version: '$1'/" snap/snapcraft.yaml
}

if [[ ! $1 =~ ${version_pattern} ]]; then
  echo './set_version.sh *.*.*[-*]'
  exit 0
fi

# Flutter
echo "change flutter about page version."
change_about_version "$1"

# Deb
echo "change deb info."
change_deb_version "$1"

# Snap
echo "change snapcraft info."
change_snap "$1"

# Arch
echo "change arch info."
change_arch "$1"
