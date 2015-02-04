How to do a release
===================

  * Update sympref.m:

      - update version number (bump and remove -git).

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

  * Then redo the packages using the tag.

      - compute the md5sums, upload the packages to github release
        page, and copy-paste the md5sums.



AFTER release
=============

  * Append -git to version in sympref.m

  * Leave old version in DESCRIPTION (-git not supported here).  We'll
    bump it at the next release.

  * Snippets should default to true in sympref.m
