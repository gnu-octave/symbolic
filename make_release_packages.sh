#!/bin/sh

# for day-to-day testing
VER=2.4.0-dev
# for release
#VER=2.4.0
#TAG=v${VER}

#----------------------------------------------------------------
PKG=symbolic-$VER
DIR=$PKG

MLPKG=octsympy-matlab-$VER
MLDIR=$MLPKG

echo "Making packages for octsympy-$VER."

printf "Press [Enter] to git clone and make packages..."
read dummy


# checkout a clean copy
rm -rf octsympy
git clone https://github.com/cbm755/octsympy.git
( cd octsympy
  if [ -z $TAG ]; then
    git checkout master
  else
    # note: its ok that this gives the "detached state" warning
    git checkout tags/${TAG}
  fi
  )



# clean up
rm -f ${PKG}.tar.gz ${PKG}.zip
rm -f ${MLPKG}.tar.gz ${MLPKG}.zip
rm -rf ${DIR}
rm -rf ${MLDIR}
cp -R octsympy ${DIR}

# remove .git dir and other things not needed for package
( cd ${DIR}/
  rm .gitignore
  rm -rf .git/
  rm -f screenshot.png
  rm -f screenshot-install.png
  )

# make clean
( cd ${DIR}/src/
  make distclean
  ./bootstrap
  rm -rf autom4te.cache
  make clean )

# here are the packages
tar -cvf - ${DIR} | gzip -9n > ${PKG}.tar.gz
zip -r ${PKG}.zip ${DIR}


# Now, matlab packages
( cd ${DIR}/src/
  make matlab )
cp -pR ${DIR}/matlab ${MLDIR}
tar -cvf - ${MLDIR} | gzip -9n > ${MLPKG}.tar.gz
zip -r ${MLPKG}.zip ${MLDIR}



md5sum ${PKG}.tar.gz ${PKG}.zip ${MLPKG}.tar.gz ${MLPKG}.zip
