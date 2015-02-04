#!/bin/sh

# for day-to-day testing
VER=2.0.0-git
# for release
#VER=2.0.0
#TAG=v${VER}

#----------------------------------------------------------------
PKG=symbolic-$VER
DIR=$PKG

MLPKG=octsympy-matlab-$VER
MLDIR=$MLPKG

echo "Making packages for octsympy-$VER."

read -p "Press [Enter] to git clone and make packages..."


# checkout a clean copy
rm -rf octsympy
git clone https://github.com/cbm755/octsympy.git
pushd octsympy
if [ -z $TAG]; then
  git checkout master
else
  git checkout tags/${TAG}
fi
popd



# clean up
rm -f ${PKG}.tar.gz ${PKG}.zip
rm -f ${MLPKG}.tar.gz ${MLPKG}.zip
rm -rf ${DIR}
rm -rf ${MLDIR}
cp -r octsympy ${DIR}

# remove .git dir and other things not needed for package
pushd ${DIR}/
rm -rf .git/
rm -f screenshot.png
rm -f screenshot-install.png
popd

# make clean
pushd ${DIR}/src/
make clean
popd

# here are the packages
tar -zcvf ${PKG}.tar.gz ${DIR}
zip -r ${PKG}.zip ${DIR}


# Now, matlab packages
pushd ${DIR}/src/
make matlab
popd
cp -ra ${DIR}/matlab ${MLDIR}
tar -zcvf ${MLPKG}.tar.gz ${MLDIR}
zip -r ${MLPKG}.zip ${MLDIR}



md5sum ${PKG}.tar.gz ${PKG}.zip ${MLPKG}.tar.gz ${MLPKG}.zip
