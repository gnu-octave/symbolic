SHELL   := /bin/bash

## Copyright 2016-2017 Colin B. Macdonald
##
## Copying and distribution of this file, with or without modification,
## are permitted in any medium without royalty provided the copyright
## notice and this notice are preserved.  This file is offered as-is,
## without any warranty.

PACKAGE := $(shell grep "^Name: " DESCRIPTION | cut -f2 -d" ")
VERSION := $(shell grep "^Version: " DESCRIPTION | cut -f2 -d" ")
MATLAB_PACKAGE_NAME := octsympy

BUILD_DIR := tmp
MATLAB_PKG := ${BUILD_DIR}/${MATLAB_PACKAGE_NAME}-matlab-${VERSION}
MATLAB_PKG_ZIP := ${BUILD_DIR}/${MATLAB_PACKAGE_NAME}-matlab-${VERSION}.zip
OCTAVE_RELEASE := ${BUILD_DIR}/${PACKAGE}-${VERSION}
OCTAVE_RELEASE_TARBALL := ${BUILD_DIR}/${PACKAGE}-${VERSION}.tar.gz

INSTALLED_PACKAGE := ~/octave/${PACKAGE}-${VERSION}/packinfo/DESCRIPTION
HTML_DIR := ${BUILD_DIR}/${PACKAGE}-html
HTML_TARBALL := ${HTML_DIR}.tar.gz

OCTAVE ?= octave
MATLAB ?= matlab

.PHONY: help clean install test doctest dist dist_zip html matlab_test matlab_pkg

help:
	@echo Available rules:
	@echo "  clean              clean all temporary files"
	@echo "  install            install package in Octave"
	@echo "  test               run tests with Octave"
	@echo "  doctest            run doctests with Octave"
	@echo "  dist               create Octave package (${OCTAVE_RELEASE_TARBALL})"
	@echo "  html               create Octave Forge website (${HTML_TARBALL})"
	@echo "  release            create both tarballs and md5 sums"
	@echo
	@echo "  matlab_test        run tests with Matlab"
	@echo "  matlab_pkg         create Matlab package (${MATLAB_PKG_ZIP})"


GIT_DATE   := $(shell git show -s --format=\%ci)
# Follows the recommendations of https://reproducible-builds.org/docs/archives
define create_tarball
$(shell cd $(dir $(1)) \
    && find $(notdir $(1)) -print0 \
    | LC_ALL=C sort -z \
    | tar c --mtime="$(GIT_DATE)" \
            --owner=root --group=root --numeric-owner \
            --no-recursion --null -T - -f - \
    | gzip -9n > "$(2)")
endef

%.tar.gz: %
	$(call create_tarball,$<,$(notdir $@))

%.zip: %
	cd "$(BUILD_DIR)" ; zip -9qr - "$(notdir $<)" > "$(notdir $@)"

$(OCTAVE_RELEASE): .git/index | $(BUILD_DIR)
	@echo "Creating package version $(VERSION) release ..."
	-$(RM) -r "$@"
	git archive --format=tar --prefix="$@/" HEAD | tar -x
	$(RM) "$@/README.matlab.md" \
	      "$@/HOWTO-release.md" \
	      "$@/TODO.md" \
	      "$@/.gitignore" \
	      "$@/.travis.yml" \
	      "$@/.mailmap" \
	      "$@/screenshot.png" \
	      "$@/screenshot-install.png"
	$(RM) -r "$@/testing" "$@/util"
	chmod -R a+rX,u+w,go-w "$@"

$(HTML_DIR): install | $(BUILD_DIR)
	@echo "Generating HTML documentation. This may take a while ..."
	-$(RM) -r "$@"
	$(OCTAVE) --no-window-system --silent \
	  --eval "pkg load generate_html; " \
	  --eval "pkg load $(PACKAGE);" \
	  --eval "options = get_html_options ('octave-forge');" \
	  --eval "generate_package_html ('${PACKAGE}', '${HTML_DIR}', options)"
	chmod -R a+rX,u+w,go-w $@

dist: $(OCTAVE_RELEASE_TARBALL)
html: $(HTML_TARBALL)
md5: $(OCTAVE_RELEASE_TARBALL) $(HTML_TARBALL)
	@md5sum $^

release: md5
	@echo "Upload @ https://sourceforge.net/p/octave/package-releases/new/"
	@echo "*After review*, an Octave-Forge admin will tag this with:"
	@echo "    git tag -a v$(VERSION) -m \"Version $(VERSION)\""


${BUILD_DIR} ${MATLAB_PKG}/private ${MATLAB_PKG}/tests_matlab ${MATLAB_PKG}/@sym ${MATLAB_PKG}/@symfun ${MATLAB_PKG}/@logical ${MATLAB_PKG}/@double:
	mkdir -p "$@"

clean:
	rm -rf "${BUILD_DIR}"
	rm -f fntests.log

test:
	@echo "Testing package in GNU Octave ..."
	@$(OCTAVE) --no-gui --silent --path "${CURDIR}/inst" \
		--eval "set (0, 'defaultfigurevisible', 'off'); \
		 anyfail = octsympy_tests; \
		 sympref reset; \
		 exit (anyfail)"
	@echo

doctest:
	@# Workaround for OctSymPy issue 273, we must pre-initialize the package
	@# Otherwise, it will make the doctests fail
	@echo "Testing documentation strings ..."
	@$(OCTAVE) --no-gui --silent --path "${CURDIR}/inst" \
		--eval "pkg load doctest; \
		 sym ('x'); \
		 set (0, 'defaultfigurevisible', 'off'); \
		 success = doctest('inst/'); \
		 sympref reset; \
		 exit (!success)"
	@echo


## Install in Octave (locally)
install: ${INSTALLED_PACKAGE}
${INSTALLED_PACKAGE}: ${OCTAVE_RELEASE_TARBALL}
	$(OCTAVE) --silent --eval "pkg install $<"

## Matlab packaging
## TODO: should be written to properly use artfacts
matlab_pkg: $(MATLAB_PKG_ZIP)

${MATLAB_PKG}: $(BUILD_DIR) ${MATLAB_PKG}/private ml_extract_tests

## Matlab: extract unit tests from Octave files, place in separate files
ml_extract_tests: ${MATLAB_PKG}/tests_matlab ml_copy
	cp -pR misc/octassert.m ${MATLAB_PKG}/tests_matlab/
	cp -pR misc/extract_tests_for_matlab.m ${MATLAB_PKG}/
	cp -pR misc/octsympy_tests_matlab.m ${MATLAB_PKG}/
	cd ${MATLAB_PKG}/; ${OCTAVE} -q --eval "extract_tests_for_matlab"
	rm -f ${MATLAB_PKG}/extract_tests_for_matlab.m
	rm -f ${MATLAB_PKG}/tests_matlab/tests__sympref.m  # temp

## Matlab: copy files
ml_copy: ml_convert_comments
	cp -pR inst/private ${MATLAB_PKG}/
	cp -pR inst/@sym/private ${MATLAB_PKG}/@sym/
	cp -pR inst/@symfun/private ${MATLAB_PKG}/@symfun/
	cp -pR misc/my_print_usage.m ${MATLAB_PKG}/private/print_usage.m
	cp -pR misc/my_print_usage.m ${MATLAB_PKG}/@sym/private/print_usage.m
	cp -pR misc/my_print_usage.m ${MATLAB_PKG}/@symfun/private/print_usage.m
	cp -fp CONTRIBUTORS ${MATLAB_PKG}/
	cp -fp NEWS ${MATLAB_PKG}/
	cp -fp COPYING ${MATLAB_PKG}/
	cp -fp matlab_smt_differences.md ${MATLAB_PKG}/
	cp -fp README.md ${MATLAB_PKG}/
	cp -fp README.matlab.md ${MATLAB_PKG}/
	rm -f ${MATLAB_PKG}/octsympy_tests.m

## Matlab: extract and convert comments to Matlab style
ml_convert_comments: ${MATLAB_PKG}/@sym ${MATLAB_PKG}/@symfun ${MATLAB_PKG}/@double ${MATLAB_PKG}/@logical
	$(OCTAVE) --path ${CURDIR}/util --silent --eval "pwd, convert_comments('inst/', '',         '../${MATLAB_PKG}/')"
	$(OCTAVE) --path ${CURDIR}/util --silent --eval "pwd, convert_comments('inst/', '@symfun',  '../${MATLAB_PKG}/')"
	$(OCTAVE) --path ${CURDIR}/util --silent --eval "pwd, convert_comments('inst/', '@sym',     '../${MATLAB_PKG}/')"
	$(OCTAVE) --path ${CURDIR}/util --silent --eval "pwd, convert_comments('inst/', '@double',  '../${MATLAB_PKG}/')"
	$(OCTAVE) --path ${CURDIR}/util --silent --eval "pwd, convert_comments('inst/', '@logical', '../${MATLAB_PKG}/')"

matlab_test:
	cd "${MATLAB_PKG}"; ${MATLAB} -nodesktop -nosplash -r "${MATLAB_STARTUP_CMD}; octsympy_tests_matlab"
