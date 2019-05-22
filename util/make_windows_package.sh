#!/bin/sh

# Copyright 2016-2019 Colin B. Macdonald
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Available from https://github.com/manthey/pyexe
PYEXE=pyexe/py27_v18.exe
# copy a few lines from https://github.com/manthey/pyexe/blob/master/README.md
PYEXEREADME=pyexe/README.pyexe.txt

# download dependencies, leave tarballs in the same directory where this script lives
SYMPY=sympy-1.4
MPMATH=mpmath-1.1.0

# for day-to-day testing
VER=2.8.0+
BRANCH=master
# for release
#VER=2.8.0
#TAG=v${VER}


###################################

WINPKG=symbolic-win-py-bundle-$VER
WINDIR=$WINPKG
WINDIRTMP=${WINDIR}-TMP

echo "Making packages for octsympy-$VER."

printf "Press [Enter] to git clone and make packages..."
read dummy

# checkout a clean copy
rm -rf octsympy
git clone https://github.com/cbm755/octsympy.git
( cd octsympy
  if [ -z $TAG]; then
    git checkout ${BRANCH}
  else
    git checkout tags/${TAG}
  fi )
pushd octsympy
GIT_DATE=`git show -s --format=\%ci`
popd


# clean up
rm -rf ${WINDIR}
rm -rf ${WINDIRTMP}

cp -R octsympy ${WINDIRTMP}

# copy things to the package
mkdir ${WINDIR}
cp -pR ${WINDIRTMP}/inst ${WINDIR}/
cp -pR ${WINDIRTMP}/NEWS ${WINDIR}/
cp -pR ${WINDIRTMP}/CONTRIBUTORS ${WINDIR}/
cp -pR ${WINDIRTMP}/DESCRIPTION ${WINDIR}/
cp -pR ${WINDIRTMP}/COPYING ${WINDIR}/
cp -pR ${WINDIRTMP}/matlab_smt_differences.md ${WINDIR}/

# bundle pyexe
mkdir ${WINDIR}/bin
cp ${PYEXE} ${WINDIR}/bin/py27.exe
cp ${PYEXEREADME} ${WINDIR}/

echo "making default python py27.exe"
sed -i "s/python = 'python'/python = 'py27.exe'/" ${WINDIR}/inst/private/defaultpython.m

echo "bundling mpmath"
tar -zxf ${MPMATH}.tar.gz || exit 1
cp -pR ${MPMATH}/mpmath ${WINDIR}/bin/ || exit 1
cp -pR ${MPMATH}/PKG-INFO ${WINDIR}/README.mpmath || exit 1
rm -rf ${MPMATH}

echo "bundling sympy"
tar -zxf ${SYMPY}.tar.gz
cp -pR ${SYMPY}/sympy ${WINDIR}/bin/ || exit 1
cp -pR ${SYMPY}/README.rst ${WINDIR}/README.sympy.rst || exit 1
rm -rf ${SYMPY}

# For Octave 5.1, we need a tar.gz file instead of a zip
#zip -r ${WINPKG}.zip ${WINDIR}
#md5sum ${WINPKG}.zip

# Follows the recommendations of https://reproducible-builds.org/docs/archives
find ${WINPKG} -print0 \
    | LC_ALL=C sort -z \
    | tar c --mtime="${GIT_DATE}" \
            --owner=root --group=root --numeric-owner \
            --no-recursion --null -T - -f - \
    | gzip -9n > ${WINPKG}.tar.gz

md5sum ${WINPKG}.tar.gz
