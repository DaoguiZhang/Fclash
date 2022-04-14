#!/bin/bash

# build linux
echo "build flutter package in $PWD"
flutter build linux --release

# rm
pushd ./debian/build-src/opt/apps/cn.kingtous.fclash/files || exit
rm -rf ./*
popd || exit

# cp
cp -r ./build/linux/x64/release/bundle/* ./debian/build-src/opt/apps/cn.kingtous.fclash/files

echo "build deb package"
pushd ./debian || exit

dpkg -b ./build-src cn.kingtous.fclash.deb

popd || exit
