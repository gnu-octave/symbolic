#!/bin/sh

# download py.exe from http://www.orbitals.com/programs/pyexe.html
PYEXE=py278.exe
PYEXEREADME=py278.readme.txt   # from the src package

# download sympy release, unpack in the directory with this script
SYMPY=sympy-0.7.5

# octsympy version
VER=0.1.0

###################################
TAG=v${VER}
PKG=octsympy-$VER
DIR=$PKG

WINPKG=octsympy-windows-$VER
WINDIR=$WINPKG
WINDIRTMP=${WINDIR}-TMP

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
rm -rf ${WINDIR}
rm -rf ${WINDIRTMP}

cp -r octsympy ${DIR}

# "make install" needs python so we make it now, then remove src from
# the package
cp -r octsympy ${WINDIRTMP}
pushd ${WINDIRTMP}/src/
make
popd

# copy things to the package
mkdir ${WINDIR}
cp -ra ${WINDIRTMP}/inst ${WINDIR}/
cp -ra ${WINDIRTMP}/NEWS ${WINDIR}/
cp -ra ${WINDIRTMP}/CONTRIBUTORS ${WINDIR}/
cp -ra ${WINDIRTMP}/DESCRIPTION ${WINDIR}/
cp -ra ${WINDIRTMP}/COPYING ${WINDIR}/
cp -ra ${WINDIRTMP}/README.bundled.md ${WINDIR}/
cp -ra ${WINDIRTMP}/matlab_smt_differences.md ${WINDIR}/

# relocate the mydbpy.bat file
mkdir ${WINDIR}/bin/
mv ${WINDIR}/inst/mydbpy.bat ${WINDIR}/bin/
# py.exe
cp ${PYEXE} ${WINDIR}/bin/py.exe
cp ${PYEXEREADME} ${WINDIR}/README.pyexe.txt
# sympy
cp -ra sympy-0.7.5/sympy ${WINDIR}/bin/
cp -ra sympy-0.7.5/README.rst ${WINDIR}/README.sympy.rst

zip -r ${WINPKG}.zip ${WINDIR}

md5sum ${WINPKG}.zip
