#!/bin/sh

# Copyright 2016-2018 Colin B. Macdonald
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Available from https://github.com/manthey/pyexe
PYEXE=pyexe/py27_v14.exe
# copy a few lines from https://github.com/manthey/pyexe/blob/master/README.md
PYEXEREADME=pyexe/README.pyexe.txt

# download dependencies, unpack in the same directory where this script lives
SYMPY=sympy-1.2
MPMATH=mpmath-1.0.0

# for day-to-day testing
VER=2.7.1-dev
BRANCH=master
# for release
#VER=2.7.1
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
cp -pR ${WINDIRTMP}/README.bundled.md ${WINDIR}/
cp -pR ${WINDIRTMP}/matlab_smt_differences.md ${WINDIR}/

# bundle pyexe
mkdir ${WINDIR}/bin
cp ${PYEXE} ${WINDIR}/bin/py27.exe
cp ${PYEXEREADME} ${WINDIR}/

# change default python to pyexe
echo "making default python py27.exe"
sed -i "s/python = 'python'/python = 'py27.exe'/" ${WINDIR}/inst/private/defaultpython.m

# bundle sympy and mpmath
cp -pR ${SYMPY}/sympy ${WINDIR}/bin/ || exit 1
cp -pR ${SYMPY}/README.rst ${WINDIR}/README.sympy.rst || exit 1
cp -pR ${MPMATH}/mpmath ${WINDIR}/bin/ || exit 1

zip -r ${WINPKG}.zip ${WINDIR}

md5sum ${WINPKG}.zip
