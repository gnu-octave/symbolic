#!/bin/sh

# download py.exe from http://www.orbitals.com/programs/pyexe.html
PYEXE=py27910.exe
PYEXEREADME=py27910.readme.txt   # from the src package

# download sympy release, unpack in the directory with this script
SYMPY=sympy-0.7.6

# for day-to-day testing
VER=2.1.1.dev
# for release
#VER=2.1.1
#TAG=v${VER}


###################################

WINPKG=symbolic-win-py-bundle-$VER
WINDIR=$WINPKG
WINDIRTMP=${WINDIR}-TMP

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
rm -rf ${WINDIR}
rm -rf ${WINDIRTMP}


cp -r octsympy ${WINDIRTMP}
pushd ${WINDIRTMP}/src/
make distclean
./bootstrap
./configure
make
popd

# copy things to the package
mkdir ${WINDIR}
cp -ra ${WINDIRTMP}/inst ${WINDIR}/
cp -ra ${WINDIRTMP}/bin ${WINDIR}/
cp -ra ${WINDIRTMP}/NEWS ${WINDIR}/
cp -ra ${WINDIRTMP}/CONTRIBUTORS ${WINDIR}/
cp -ra ${WINDIRTMP}/DESCRIPTION ${WINDIR}/
cp -ra ${WINDIRTMP}/COPYING ${WINDIR}/
cp -ra ${WINDIRTMP}/README.bundled.md ${WINDIR}/
cp -ra ${WINDIRTMP}/matlab_smt_differences.md ${WINDIR}/

# py.exe
cp ${PYEXE} ${WINDIR}/bin/py.exe
cp ${PYEXEREADME} ${WINDIR}/README.pyexe.txt

# change default python to py.exe
echo "making default python py.exe"
sed -i "s/pyexec = 'python'/pyexec = 'py.exe'/" ${WINDIR}/inst/private/python_ipc_sysoneline.m
sed -i "s/pyexec = 'python'/pyexec = 'py.exe'/" ${WINDIR}/inst/private/python_ipc_system.m

# sympy
cp -ra ${SYMPY}/sympy ${WINDIR}/bin/ || exit -6
cp -ra ${SYMPY}/README.rst ${WINDIR}/README.sympy.rst || exit -6

zip -r ${WINPKG}.zip ${WINDIR}

md5sum ${WINPKG}.zip
