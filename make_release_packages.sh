#!/bin/sh

VER=0.0.3
TAG=v${VER}
PKG=octsympy-$VER
DIR=$PKG

echo "Making packages for octsympy-$VER."

read -p "Press [Enter] to git clone and make packages..."


# checkout a clean copy
rm -rf octsympy
git clone https://github.com/cbm755/octsympy.git
pushd octsympy
# for testing before tagging
#git checkout master
git checkout tags/${TAG}
popd



# clean up
rm -f ${PKG}.tar.gz ${PKG}.zip
rm -rf ${DIR}
cp -r octsympy ${DIR}

# remove .git dir and other things not needed for package
pushd ${DIR}/
rm -rf .git/
rm -f screenshot.png
popd

# make clean
pushd ${DIR}/src/
make clean
popd

# here are the packages
tar -zcvf ${PKG}.tar.gz ${DIR}
zip -r ${PKG}.zip ${DIR}

md5sum ${PKG}.tar.gz ${PKG}.zip
