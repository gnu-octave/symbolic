SHELL   = /bin/bash

PACKAGE = $(shell grep "^Name: " DESCRIPTION | cut -f2 -d" ")
VERSION = $(shell grep "^Version: " DESCRIPTION | cut -f2 -d" ")
CC_SOURCES = $(wildcard src/*.cc)
BUILD_DIR = tmp
MATLAB_PKG_DIR=${PACKAGE}-matlab-${VERSION}
OCTAVE_RELEASE_TARBALL = ${BUILD_DIR}/${PACKAGE}-${VERSION}.tar
OCTAVE_RELEASE_TARBALL_COMPRESSED = ${OCTAVE_RELEASE_TARBALL}.gz
INSTALLED_PACKAGE = ~/octave/${PACKAGE}-${VERSION}/packinfo/DESCRIPTION
HTML_DIR = ${BUILD_DIR}/${PACKAGE}-html
HTML_TARBALL_COMPRESSED = ${HTML_DIR}.tar.gz
OCT_COMPILED = ${BUILD_DIR}/.oct

OCTAVE ?= octave
MKOCTFILE ?= mkoctfile -Wall
MATLAB ?= matlab

TEST_CODE=success = doctest({'doctest', 'test/', 'test/examples/'}); exit(~success);


.PHONY: help clean install test test-interactive matlab_test matlab_pkg octave_pkg octave_html

help:
	@echo Available rules:
	@echo "  clean              clean all temporary files"
	@echo "  install            install package in Octave"
	@echo "  test               run tests with Octave"
	@echo "  test-interactive   run tests with Octave in interactive mode"
	@echo "  matlab_test        run tests with Matlab"
	@echo "  matlab_pkg         create Matlab package (${MATLAB_PKG_DIR}.zip)"
	@echo "  octave_pkg         create Octave package (${OCTAVE_RELEASE_TARBALL_COMPRESSED})"
	@echo "  octave_html        create Octave Forge website"


${BUILD_DIR} ${BUILD_DIR}/${MATLAB_PKG_DIR}/private:
	mkdir -p "$@"

clean:
	rm -rf "${BUILD_DIR}"
	rm -f src/*.oct src/*.o

## If the src/Makefile changes, recompile all oct-files
${CC_SOURCES}: src/Makefile
	@touch --no-create "$@"

## Compilation of oct-files happens in a separate Makefile,
## which is bundled in the release and will be used during
## package installation by Octave.
${OCT_COMPILED}: ${CC_SOURCES} | ${BUILD_DIR}
	MKOCTFILE="${MKOCTFILE}" ${MAKE} -C src
	@touch "$@"


test: ${OCT_COMPILED}
	${OCTAVE} --path ${PWD}/inst --path ${PWD}/src --eval "${TEST_CODE}"

test-interactive: ${OCT_COMPILED}
	script --quiet --command "${OCTAVE} --path ${PWD}/inst --path ${PWD}/src --eval \"${TEST_CODE}\"" /dev/null


matlab_test:
	${MATLAB} -nojvm -nodisplay -nosplash -r "addpath('inst'); ${TEST_CODE}"

## Install in Octave (locally)
install: ${INSTALLED_PACKAGE}
${INSTALLED_PACKAGE}: ${OCTAVE_RELEASE_TARBALL_COMPRESSED}
	$(OCTAVE) --silent --eval "pkg install $<"

## Package release for Octave
${OCTAVE_RELEASE_TARBALL}: .git/index | ${BUILD_DIR}
	git archive --output="$@" --prefix=${PACKAGE}-${VERSION}/ HEAD
	tar --delete --file "$@" ${PACKAGE}-${VERSION}/README.matlab.md
octave_pkg: ${OCTAVE_RELEASE_TARBALL_COMPRESSED}
${OCTAVE_RELEASE_TARBALL_COMPRESSED}: ${OCTAVE_RELEASE_TARBALL}
	(cd "${BUILD_DIR}" && gzip --best -f -k "../$<")

## HTML Documentation for Octave Forge
octave_html: ${HTML_TARBALL_COMPRESSED}
${HTML_TARBALL_COMPRESSED}: ${INSTALLED_PACKAGE} | ${BUILD_DIR}
	rm -rf "${HTML_DIR}"
	$(OCTAVE) --silent --eval \
		"pkg load generate_html; \
		 options = get_html_options ('octave-forge'); \
		 generate_package_html ('${PACKAGE}', '${HTML_DIR}', options)"
	tar --create --auto-compress --transform="s!^${BUILD_DIR}/!!" --file "$@" "${HTML_DIR}"

matlab_pkg: | ${BUILD_DIR}/${MATLAB_PKG_DIR}/private
	$(OCTAVE) --path ${PWD}/util --silent --eval \
		"convert_comments('inst/', '', '../${BUILD_DIR}/${MATLAB_PKG_DIR}/')"
	cp -ra inst/private/*.m ${BUILD_DIR}/${MATLAB_PKG_DIR}/private/
	cp -ra COPYING ${BUILD_DIR}/${MATLAB_PKG_DIR}/
	cp -ra CONTRIBUTORS ${BUILD_DIR}/${MATLAB_PKG_DIR}/
	cp -ra NEWS ${BUILD_DIR}/${MATLAB_PKG_DIR}/
	cp -ra README.matlab.md ${BUILD_DIR}/${MATLAB_PKG_DIR}/
	pushd ${BUILD_DIR}; zip -r ${MATLAB_PKG_DIR}.zip ${MATLAB_PKG_DIR}; popd
