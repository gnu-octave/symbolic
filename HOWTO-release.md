How to do a release
===================

We use x.y.z.  Bump y for minor changes or z for "micro" changes (bug
fixes etc).

OctaveForge process: http://octave.sourceforge.net/developers.html
TODO: read this during next release, and update below.


Checklist
---------

  * Update sympref.m:

      - update version number (remove "-dev", check if bump needed).

  * Update DESCRIPTION file (version number and date).

  * Update NEWS file (date, version number, reformat).

  * Check minimum sympy version is consistent: its in
    DESCRIPTION, assert_have_python_and_sympy.m

  * Packages: need to run the following two scripts:

      - Use the maintainer makefile: "make clean", "make dist".

      - make_windows_package.sh, use "day-to-day testing" mode.
        Run this script "out of tree", it will clone a clean copy.
        Make sure py2exe and sympy are the most recent versions.

  * Test regenerating html documentation: "make html"

  * Run "make release" and record the md5 sums.

  * Test on Matlab if possible.

  * Test on Windows if possible.

  * Ensure sourceforge and github both have up-to-date master.

  * Create ticket for release on sourceforge.  Upload tarball, html
    tarball and md5sums.

  * Update 2017-07: tagging now happens after review, by admins!

      - If packages seem ok, admin/reviewer will tag with:

          `git tag -a v2.x.y -m "Version 2.x.y"`

  * Make sure tags are current on both sourceforge and github.
    `git push --tags origin master`.

  * Do github related release tasks:

      - Redo the Windows bundle package (using tag mode, see script).

      - compute the md5sums, upload the packages to github release
        page, and copy-paste the md5sums.  These must match the
        sourceforge md5sums.

      - Do github release (copy-paste from last time, update link).



AFTER release
=============

  * Bump version to the next anticipated version and append "-dev" in
    in sympref.m.  See
    [PEP 440](https://www.python.org/dev/peps/pep-0440).

  * Optionally, update the make_windows_bundle script.

  * Leave old version in DESCRIPTION ("-dev" not supported here).  We
    will bump it at the next release.  FIXME: this is unfortunate.
