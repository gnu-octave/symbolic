How to do a release
===================

We use x.y.z.  Bump y for minor changes or z for "micro" changes (bug
fixes etc).

OctaveForge process: http://octave.sourceforge.net/developers.html
TODO: read this during next release, and update below.


Checklist
---------

  * Update sympref.m:

      - update version number (remove ".dev", check if bump needed).

      - Make sure snippet defaults to false.

  * Update DESCRIPTION file (version number and date).

  * Update NEWS file (date, version number, reformat).

  * Packages: need to run the following two scripts.  I recommend
    testing them first without using the tag.  Then test the packages
    by running the test suite.

      - make_release_packages.sh, use "day-to-day testing" mode instead
        of tag.

      - make_windows_package.sh, use "day-to-day testing" mode.

  * If packages seem ok, then tag the repo with:

    `git tag -a v2.0.0 -m "Version 2.0.0"`

  * `git push --tags origin master`.  If messed up and want to change
    anything after this, need to bump version number (tag is public).

  * Push and push tags to sourceforge.

  * Then redo the packages using the "tag" mode.

      - compute the md5sums, upload the packages to github release
        page, and copy-paste the md5sums.

      - do something with binaries on sourceforge.



AFTER release
=============

  * Bump version to the next anticipated version and append ".dev" in
    in sympref.m.  See
    [PEP 440](https://www.python.org/dev/peps/pep-0440).

  * Leave old version in DESCRIPTION (".dev" not supported here).  We
    will bump it at the next release.  FIXME: this is unfortunate.

  * Snippets could default to true in sympref.m
