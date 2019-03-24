%% Copyright (C) 2014, 2016-2017, 2019 Colin B. Macdonald
%%
%% This file is part of OctSymPy.
%%
%% OctSymPy is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published
%% by the Free Software Foundation; either version 3 of the License,
%% or (at your option) any later version.
%%
%% This software is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty
%% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
%% the GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public
%% License along with this software; see the file COPYING.
%% If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @defun octsympy_tests ()
%% Run the test suite, log results, and return true if any fail.
%%
%% On recent Octave, this is a thin layer around the built-in Octave
%% command @code{__run_test_suite__ (@{'.'@}, @{@})}.
%%
%% Testing should work once the package is installed, which is otherwise
%% harder to test (need to know the installation directory).
%%
%% TODO: eventually we should drop this file altogether, but then how
%% do we test the installed package?  Perhaps we could keep this here
%% until @code{pkg test} works upstream: @url{https://savannah.gnu.org/bugs/?41215}
%%
%% @seealso{test, runtests, doctest}
%% @end defun

function anyfail = octsympy_tests ()
  if (compare_versions (OCTAVE_VERSION (), '4.4.0', '>='))
    pkgdir = fileparts (mfilename ('fullpath'))
    % Maybe later: https://savannah.gnu.org/bugs/?55841
    %if (strcmp (fullfile (pkgdir), fullfile (pwd)))
    %  % be quieter if pkgdir is the current dir
    %  pkgdir = '.';
    %end
    [pass, fail] = __run_test_suite__ ({pkgdir}, {});
    anyfail = fail > 0;
    return
  end

  %% Deprecated: this code to be removed when we drop support for < 4.4.0.
  % The remainder of this is an old fork of "__run_test_suite__.m" which is
  % Copyright (C) 2005-2013 David Bateman and part of GNU Octave, GPL v3.

  fcndirs = { '.'
              '@logical'
              '@double'
              '@sym'
              '@symfun' };
  mycwd = pwd ();
  mydir = fileparts (mfilename ('fullpath'));
  chdir (mydir);
  % I had trouble with global vars, so just return them
  files_with_no_tests = {};
  files_with_tests = {};
  pso = page_screen_output ();
  warn_state = warning ("query", "quiet");
  warning ("on", "quiet");
  % time it all
  totaltime = clock();
  totalcputime = cputime();
  % get the octsympy startup text out of way before we start
  syms x
  try
    page_screen_output (false);
    warning ("off", "Octave:deprecated-function");
    fid = fopen (fullfile(mycwd, "fntests.log"), "wt");
    if (fid < 0)
      error ("could not open fntests.log for writing");
    endif
    test ("", "explain", fid);
    dp = dn = dxf = dsk = 0;
    puts ("\nIntegrated test scripts:\n\n");
    for i = 1:length (fcndirs)
      [p, n, xf, sk, FWT, FWNT] = run_test_script (fid, fcndirs{i});
      dp += p;
      dn += n;
      dxf += xf;
      dsk += sk;
      files_with_tests = {files_with_tests{:} FWT{:}};
      files_with_no_tests = {files_with_no_tests{:} FWNT{:}};
    endfor
    fclose (fid);

    puts ("\nSummary:\n\n");

    nfail = dn - dp - dxf;
    printf ("  PASS    %6d\n", dp);
    printf ("  FAIL    %6d\n", nfail);
    if (dxf > 0)
      printf ("  XFAIL   %6d\n", dxf);
    endif
    if (dsk > 0)
      printf ("  SKIPPED %6d\n", dsk);
    endif
    totaltime = etime(clock(), totaltime);
    totalcputime = cputime() - totalcputime;
    fprintf ('  TIME %8.0fs (%.0fs CPU)\n', totaltime, totalcputime);
    puts ("\n");

    puts ("See the file fntests.log for additional details.\n");
    if (dxf > 0)
      puts ("\n");
      puts ("Expected failures (listed as XFAIL above) are usually known bugs.\n");
      puts ("Help is always appreciated.\n");
    endif
    if (dsk > 0)
      puts ("\n");
      puts ("Tests are most often skipped because the features they require\n");
      puts ("have been disabled.\n");
    endif

    ## Weed out deprecated and private functions
    #weed_idx = cellfun (@isempty, regexp (files_with_tests, '\<deprecated\>|\<private\>', 'once'));
    #files_with_tests = files_with_tests(weed_idx);
    #weed_idx = cellfun (@isempty, regexp (files_with_no_tests, '\<deprecated\>|\<private\>', 'once'));
    #files_with_no_tests = files_with_no_tests(weed_idx);

    report_files_with_no_tests (files_with_tests, files_with_no_tests, ".m");
    printf("\n");
    printf (list_in_columns (files_with_no_tests, 80));

    anyfail = nfail > 0;

    page_screen_output (pso);
    warning (warn_state.state, "quiet");
  catch
    page_screen_output (pso);
    warning (warn_state.state, "quiet");
    disp (lasterr ());
  end_try_catch
  chdir (mycwd);
endfunction


function print_test_file_name (nm)
  filler = repmat (".", 1, 48-length (nm));
  printf ("  %s %s", nm, filler);
endfunction


function print_pass_fail (p, n, xf, sk)
  if ((n + sk) > 0)
    printf (" PASS %3d/%-3d", p, n);
    nfail = n - p - xf;
    if (nfail > 0)
      printf (" \033[1;40;31m %s %d\033[m", "FAIL", nfail);
    endif
    if (sk > 0)
      printf (" \033[1;40;33m %s %d\033[m", "SKIP", sk);
    endif
    if (xf > 0)
      printf (" \033[1;40;33m %s %d\033[m", "XFAIL", xf);
    endif
  endif
  puts ("\n");
endfunction


function retval = has_functions (f)
  n = length (f);
  if (n > 3 && strcmpi (f((end-2):end), ".cc"))
    fid = fopen (f);
    if (fid >= 0)
      str = fread (fid, "*char")';
      fclose (fid);
      retval = ! isempty (regexp (str,'^(DEFUN|DEFUN_DLD)\>',
                                      'lineanchors', 'once'));
    else
      error ("fopen failed: %s", f);
    endif
  elseif (n > 2 && strcmpi (f((end-1):end), ".m"))
    retval = true;
  else
    retval = false;
  endif
endfunction


function retval = has_tests (f)
  fid = fopen (f);
  if (fid >= 0)
    str = fread (fid, "*char")';
    fclose (fid);
    retval = ! isempty (regexp (str,
                                '^%!(assert|error|fail|test|xtest|warning)',
                                'lineanchors', 'once'));
  else
    error ("fopen failed: %s", f);
  endif
endfunction


function [dp, dn, dxf, dsk, FWT, FWNT] = run_test_script (fid, d);
  FWT = {};
  FWNT = {};

  lst = dir (d);
  dp = dn = dxf = dsk = 0;
  for i = 1:length (lst)
    nm = lst(i).name;
    ## # recurve into subdirs
    ## if (lst(i).isdir && nm(1) != ".")
    ##   [p, n, xf, sk, myFWT, myFWNT] = run_test_script (fid, [d, filesep, nm]);
    ##   dp += p;
    ##   dn += n;
    ##   dxf += xf;
    ##   dsk += sk;
    ##   FWT = {FWT{:} myFWT{:}};
    ##   FWNT = {FWNT{:} myFWNT{:}};
    ## endif
  endfor
  for i = 1:length (lst)
    nm = lst(i).name;
    ## Ignore hidden files
    if (nm(1) == '.')
      continue
    endif
    f = fullfile (d, nm);
    if ((length (nm) > 2 && strcmpi (nm((end-1):end), ".m"))
        || (length (nm) > 4
            && (   strcmpi (nm((end-3):end), "-tst")
                || strcmpi (nm((end-3):end), ".tst"))))
      p = n = xf = 0;
      ## Only run if it contains %!test, %!assert, %!error, %!fail, or %!warning
      if (has_tests (f))
        tmp = f;
        print_test_file_name (tmp);
        [p, n, xf, sk] = test (f, "quiet", fid);
        if (compare_versions (OCTAVE_VERSION (), '3.9', '<'))
          p -= xf;
        end
        print_pass_fail (p, n, xf, sk);
        dp += p;
        dn += n;
        dxf += xf;
        dsk += sk;
        FWT{end+1} = f;
      else
        ## To reduce the list length, only mark .cc files that contain
        ## DEFUN definitions.
        FWNT{end+1} = f;
      endif
    endif
  endfor
  #printf("%s%s -> passes %d of %d tests\n", ident, d, dp, dn);
endfunction


function n = num_elts_matching_pattern (lst, pat)
  n = sum (! cellfun ("isempty", regexp (lst, pat, 'once')));
endfunction


function report_files_with_no_tests (with, without, typ)
  pat = ['\' typ "$"];
  n_with = num_elts_matching_pattern (with, pat);
  n_without = num_elts_matching_pattern (without, pat);
  n_tot = n_with + n_without;
  printf ("\n%d (of %d) %s files have no tests:\n", n_without, n_tot, typ);
endfunction


% muhaha, no one is watching the watchers
%!assert(true)
