#!/bin/sh

# Copyright 2016-2017 Colin B. Macdonald
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# download py.exe from http://www.orbitals.com/programs/pyexe.html
PYEXE=py27910.exe
PYEXEREADME=py27910.readme.txt   # from the src package

# download dependencies, unpack in the same directory where this script lives
SYMPY=sympy-1.1.1
MPMATH=mpmath-0.19

# for day-to-day testing
VER=2.6.1-dev
# for release
#VER=2.6.1
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
    git checkout master
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
cp -pR ${WINDIRTMP}/bin ${WINDIR}/
cp -pR ${WINDIRTMP}/NEWS ${WINDIR}/
cp -pR ${WINDIRTMP}/CONTRIBUTORS ${WINDIR}/
cp -pR ${WINDIRTMP}/DESCRIPTION ${WINDIR}/
cp -pR ${WINDIRTMP}/COPYING ${WINDIR}/
cp -pR ${WINDIRTMP}/README.bundled.md ${WINDIR}/
cp -pR ${WINDIRTMP}/matlab_smt_differences.md ${WINDIR}/

# octpy.exe(renamed to avoid any conflicts)
cp ${PYEXE} ${WINDIR}/bin/octpy.exe
cp ${PYEXEREADME} ${WINDIR}/README.pyexe.txt

# change default python to octpy.exe
echo "making default python octpy.exe"
sed -i "s/python = 'python'/python = 'octpy.exe'/" ${WINDIR}/inst/private/defaultpython.m

# sympy and mpmath
cp -pR ${SYMPY}/sympy ${WINDIR}/bin/ || exit 1
cp -pR ${SYMPY}/README.rst ${WINDIR}/README.sympy.rst || exit 1
cp -pR ${MPMATH}/mpmath ${WINDIR}/bin/ || exit 1

zip -r ${WINPKG}.zip ${WINDIR}

md5sum ${WINPKG}.zip
