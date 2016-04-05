#!/bin/sh

# download py.exe from http://www.orbitals.com/programs/pyexe.html
PYEXE=py27910.exe
PYEXEREADME=py27910.readme.txt   # from the src package

# download sympy release, unpack in the directory with this script
SYMPY=sympy-1.0

# for day-to-day testing
VER=2.3.0-dev
# for release
#VER=2.3.0
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
( cd ${WINDIRTMP}/src/
  make distclean
  ./bootstrap
  ./configure
  make )

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
sed -i "s/pyexec = 'python'/pyexec = 'octpy.exe'/" ${WINDIR}/inst/private/python_ipc_sysoneline.m
sed -i "s/pyexec = 'python'/pyexec = 'octpy.exe'/" ${WINDIR}/inst/private/python_ipc_system.m
sed -i 's/python.exe/octpy.exe/g' ${WINDIR}/bin/winwrapy.bat

# sympy
cp -pR ${SYMPY}/sympy ${WINDIR}/bin/ || exit 1
cp -pR ${SYMPY}/README.rst ${WINDIR}/README.sympy.rst || exit 1

zip -r ${WINPKG}.zip ${WINDIR}

md5sum ${WINPKG}.zip
