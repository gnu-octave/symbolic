How to do a release
===================

We use x.y.z.  Bump y for minor changes or z for "micro" changes (bug
fixes etc).

Old OctaveForge process: http://octave.sourceforge.net/developers.html
which is changing, some comments on this below.


Checklist
---------

  * Update sympref.m:

      - update version number (remove "+", check if bump needed).

  * Update DESCRIPTION file (version number and date).

  * Update NEWS file (date, version number, reformat).

  * Update INDEX file for any new functions.

  * Check minimum sympy version is consistent: its in
    DESCRIPTION, assert_have_python_and_sympy.m

  * Packages: need to run the following two scripts:

      - Use the maintainer makefile: "make clean", "make dist".

      - DEPRECATED: make_windows_package.sh, use "day-to-day testing" mode.
        Run this script "out of tree", it will clone a clean copy.
        Make sure py2exe, mpmath, sympy are the most recent versions.

  * Test regenerating html documentation: "make html"

  * Run "make release" and record the md5 sums.

  * Test on Matlab if possible.

  * Test on Windows if possible.

  * Ensure sourceforge and github both have up-to-date main branch.

  * tag `git tag -a v3.x.y -m "Version 3.x.y"`

  * Make sure tags are current on both sourceforge and github.
    `git push --tags origin main`.
    `git push --tags sourceforge main`.
    (cbm can do this part, TODO and it may not be necessary long term)


  * DEPRECATED Sourceforge ticket
      - Create ticket for release on sourceforge.  Upload tarball, html
        tarball and md5sums.
      - get checklist https://wiki.octave.org/Reviewing_Octave_Forge_packages
      - fill it out as best we can
      - Ticket should include the git hash to be tagged.

  * Upload package to SourceForge (TODO: may change in future)

      - I use their Web UI to upload the tarball.
      - Follow the admin instructions under the review wiki above:
          `sftp` is useful for looking, and can then use `rsync`, something like
          `rsync -auvn --delete ./tmp/symbolic-html/symbolic/ <user>@web.sourceforge.net:/home/project-web/octave/htdocs/packages/symbolic/`
          (only certain users can do this: ask cbm for now)

  * Do github-related release tasks:

      - DEPRECATED: Redo the Windows bundle package (using tag mode, see script).

      - compute the md5sums, upload the packages to github release
        page, and copy-paste the md5sums.  These must match the
        sourceforge md5sums.  Also compute sha256sum.

      - Do github release (copy-paste from last time, update link).

      - upload tarball to GitHub release as well.

  * Update the https://gnu-octave.github.io/packages/ yaml file

      - see https://github.com/gnu-octave/packages/blob/main/CONTRIBUTING.md

      - send pull request


AFTER release
=============

  * Bump version by appending "+" in sympref.m and DESCRIPTION, and creating a new header in NEWS.

  * Optionally, update the make_windows_bundle script.  DEPRECATED.
