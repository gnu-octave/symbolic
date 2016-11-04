SHELL   = /bin/bash

## Copyright 2016 Colin B. Macdonald
##
## Copying and distribution of this file, with or without modification,
## are permitted in any medium without royalty provided the copyright
## notice and this notice are preserved.  This file is offered as-is,
## without any warranty.

PACKAGE = $(shell grep "^Name: " DESCRIPTION | cut -f2 -d" ")
VERSION = $(shell grep "^Version: " DESCRIPTION | cut -f2 -d" ")
MATLAB_PACKAGE = octsympy
BUILD_DIR = tmp
MATLAB_PKG_DIR=${MATLAB_PACKAGE}-matlab-${VERSION}
OCTAVE_RELEASE_TARBALL = ${BUILD_DIR}/${PACKAGE}-${VERSION}.tar
OCTAVE_RELEASE_TARBALL_COMPRESSED = ${OCTAVE_RELEASE_TARBALL}.gz
INSTALLED_PACKAGE = ~/octave/${PACKAGE}-${VERSION}/packinfo/DESCRIPTION
HTML_DIR = ${BUILD_DIR}/${PACKAGE}-html
HTML_TARBALL_COMPRESSED = ${HTML_DIR}.tar.gz

OCTAVE ?= octave
MATLAB ?= matlab

.PHONY: help clean install test doctest pkg html matlab_test matlab_pkg

help:
	@echo Available rules:
	@echo "  clean              clean all temporary files"
	@echo "  install            install package in Octave"
	@echo "  test               run tests with Octave"
	@echo "  doctest            run doctests with Octave"
	@echo "  pkg                create Octave package (${OCTAVE_RELEASE_TARBALL_COMPRESSED})"
	@echo "  html               create Octave Forge website"
	@echo
	@echo "  matlab_test        run tests with Matlab"
	@echo "  matlab_pkg         create Matlab package (${MATLAB_PKG_DIR}.zip)"



${BUILD_DIR} ${BUILD_DIR}/${MATLAB_PKG_DIR}/private ${BUILD_DIR}/${MATLAB_PKG_DIR}/tests_matlab ${BUILD_DIR}/${MATLAB_PKG_DIR}/@sym ${BUILD_DIR}/${MATLAB_PKG_DIR}/@symfun ${BUILD_DIR}/${MATLAB_PKG_DIR}/@logical:
	mkdir -p "$@"

clean:
	rm -rf "${BUILD_DIR}"
	@#rm -f fntests.log
	rm -f octsympy_tests.log

test:
	@echo "Testing package in GNU Octave ..."
	@$(OCTAVE) --no-gui --silent --path "${PWD}/inst" \
		--eval "set (0, 'defaultfigurevisible', 'off'); \
		 octsympy_tests; \
		 sympref reset"
	@! grep '!!!!! test failed' octsympy_tests.log
	@echo

doctest:
	@# Workaround for OctSymPy issue 273, we must pre-initialize the package
	@# Otherwise, it will make the doctests fail
	@echo "Testing documentation strings ..."
	@$(OCTAVE) --no-gui --silent --path "${PWD}/inst" \
		--eval "pkg load doctest; \
		 sym ('x'); \
		 set (0, 'defaultfigurevisible', 'off'); \
		 success = doctest('inst/'); \
		 sympref reset; \
		 exit (!success)"
	@echo


## Install in Octave (locally)
install: ${INSTALLED_PACKAGE}
${INSTALLED_PACKAGE}: ${OCTAVE_RELEASE_TARBALL_COMPRESSED}
	$(OCTAVE) --silent --eval "pkg install $<"

## Package release for Octave
${OCTAVE_RELEASE_TARBALL}: .git/index | ${BUILD_DIR}
	git archive --output="$@" --prefix=${PACKAGE}-${VERSION}/ HEAD
	tar --delete --file "$@" ${PACKAGE}-${VERSION}/README.matlab.md
	tar --delete --file "$@" ${PACKAGE}-${VERSION}/HOWTO-release.md
	tar --delete --file "$@" ${PACKAGE}-${VERSION}/README.bundled.md
	tar --delete --file "$@" ${PACKAGE}-${VERSION}/TODO.md
	tar --delete --file "$@" ${PACKAGE}-${VERSION}/testing
	tar --delete --file "$@" ${PACKAGE}-${VERSION}/util
	tar --delete --file "$@" ${PACKAGE}-${VERSION}/.gitignore
	tar --delete --file "$@" ${PACKAGE}-${VERSION}/.mailmap
	tar --delete --file "$@" ${PACKAGE}-${VERSION}/screenshot*.png
pkg: ${OCTAVE_RELEASE_TARBALL_COMPRESSED}
${OCTAVE_RELEASE_TARBALL_COMPRESSED}: ${OCTAVE_RELEASE_TARBALL}
	(cd "${BUILD_DIR}" && gzip --best -f -k "../$<")
## TODO: make zip file

## HTML Documentation for Octave Forge
html: ${HTML_TARBALL_COMPRESSED}
${HTML_TARBALL_COMPRESSED}: ${INSTALLED_PACKAGE} | ${BUILD_DIR}
	rm -rf "${HTML_DIR}"
	$(OCTAVE) --silent --eval \
		"pkg load generate_html; \
		 options = get_html_options ('octave-forge'); \
		 generate_package_html ('${PACKAGE}', '${HTML_DIR}', options)"
	tar --create --auto-compress --transform="s!^${BUILD_DIR}/!!" --file "$@" "${HTML_DIR}"

## Matlab packaging
matlab_pkg: ${BUILD_DIR}/${MATLAB_PKG_DIR}/private ml_extract_tests
	pushd ${BUILD_DIR}; zip -r ${MATLAB_PKG_DIR}.zip ${MATLAB_PKG_DIR}; popd

## Matlab: extract unit tests from Octave files, place in separate files
ml_extract_tests: ${BUILD_DIR}/${MATLAB_PKG_DIR}/tests_matlab ml_copy
	cp -pR misc/octassert.m ${BUILD_DIR}/${MATLAB_PKG_DIR}/tests_matlab/
	cp -pR misc/extract_tests_for_matlab.m ${BUILD_DIR}/${MATLAB_PKG_DIR}/
	cp -pR misc/octsympy_tests_matlab.m ${BUILD_DIR}/${MATLAB_PKG_DIR}/
	cd ${BUILD_DIR}/${MATLAB_PKG_DIR}/; ${OCTAVE} -q --eval "extract_tests_for_matlab"
	rm -f ${BUILD_DIR}/${MATLAB_PKG_DIR}/extract_tests_for_matlab.m

## Matlab: copy files
ml_copy: ml_convert_comments
	cp -pR inst/private ${BUILD_DIR}/${MATLAB_PKG_DIR}/
	cp -pR inst/@sym/private ${BUILD_DIR}/${MATLAB_PKG_DIR}/@sym/
	cp -pR inst/@symfun/private ${BUILD_DIR}/${MATLAB_PKG_DIR}/@symfun/
	cp -pR misc/my_print_usage.m ${BUILD_DIR}/${MATLAB_PKG_DIR}/private/print_usage.m
	cp -pR misc/my_print_usage.m ${BUILD_DIR}/${MATLAB_PKG_DIR}/@sym/private/print_usage.m
	cp -pR misc/my_print_usage.m ${BUILD_DIR}/${MATLAB_PKG_DIR}/@symfun/private/print_usage.m
	cp -fp CONTRIBUTORS ${BUILD_DIR}/${MATLAB_PKG_DIR}/
	cp -fp NEWS ${BUILD_DIR}/${MATLAB_PKG_DIR}/
	cp -fp COPYING ${BUILD_DIR}/${MATLAB_PKG_DIR}/
	cp -fp matlab_smt_differences.md ${BUILD_DIR}/${MATLAB_PKG_DIR}/
	cp -fp README.md ${BUILD_DIR}/${MATLAB_PKG_DIR}/
	cp -fp README.matlab.md ${BUILD_DIR}/${MATLAB_PKG_DIR}/
	rm -f ${BUILD_DIR}/${MATLAB_PKG_DIR}/octsympy_tests.m

## Matlab: extract and convert comments to Matlab style
ml_convert_comments: ${BUILD_DIR}/${MATLAB_PKG_DIR}/@sym ${BUILD_DIR}/${MATLAB_PKG_DIR}/@symfun ${BUILD_DIR}/${MATLAB_PKG_DIR}/@symfun/private ${BUILD_DIR}/${MATLAB_PKG_DIR}/@logical
	$(OCTAVE) --path ${PWD}/util --silent --eval "pwd, convert_comments('inst/', '',         '../${BUILD_DIR}/${MATLAB_PKG_DIR}/')"
	$(OCTAVE) --path ${PWD}/util --silent --eval "pwd, convert_comments('inst/', '@symfun',  '../${BUILD_DIR}/${MATLAB_PKG_DIR}/')"
	$(OCTAVE) --path ${PWD}/util --silent --eval "pwd, convert_comments('inst/', '@sym',     '../${BUILD_DIR}/${MATLAB_PKG_DIR}/')"
	$(OCTAVE) --path ${PWD}/util --silent --eval "pwd, convert_comments('inst/', '@logical', '../${BUILD_DIR}/${MATLAB_PKG_DIR}/')"


matlab_test:
	${MATLAB} -nojvm -nodisplay -nosplash -r "addpath('inst'); octsympy_tests_matlab"
