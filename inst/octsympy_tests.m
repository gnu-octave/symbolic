%% Copyright (C) 2014 Colin B. Macdonald
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
%% @deftypefn  {Function File} {@var{r} =} octsympy_tests ()
%% Run the tests, log results, and return true if passing.
%%
%% I threw this together by modifying "__run_test_suite__.m" which
%% is Copyright (C) 2005-2013 David Bateman and part of GNU Octave,
%% GPL v3.
%%
%% @end deftypefn

%% Author: Colin B. Macdonald, David Bateman
%% Keywords: tests

function anyfail = octsympy_tests ()
  fcndirs = { '.'
              '@logical'
              '@sym'
              '@symfun' };
  % I had trouble with global vars, so just return them
  files_with_no_tests = {};
  files_with_tests = {};
  pso = page_screen_output ();
  warn_state = warning ("query", "quiet");
  warning ("on", "quiet");
  syms x
  try
    page_screen_output (false);
    warning ("off", "Octave:deprecated-function");
    fid = fopen ("fntests.log", "wt");
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

    nfail = dn - dp;
    printf ("  PASS    %6d\n", dp);
    printf ("  FAIL    %6d\n", nfail);
    if (dxf > 0)
      printf ("  XFAIL   %6d\n", dxf);
    endif
    if (dsk > 0)
      printf ("  SKIPPED %6d\n", dsk);
    endif
    puts ("\n");
    puts ("See the file test/fntests.log for additional details.\n");
    if (dxf > 0)
      puts ("\n");
      puts ("Expected failures (listed as XFAIL above) are known bugs.\n");
      puts ("Please help improve OctSymPy (or upstream Octave/SymPy as appropriate).\n");
    endif
    if (dsk > 0)
      puts ("\n");
      puts ("Tests are most often skipped because the features they require\n");
      puts ("have been disabled.  Features are most often disabled because\n");
      puts ("they require dependencies that were not present when Octave\n");
      puts ("was built.  The configure script should have printed a summary\n");
      puts ("at the end of its run indicating which dependencies were not found.\n");
    endif

    ## Weed out deprecated and private functions
    #weed_idx = cellfun (@isempty, regexp (files_with_tests, '\<deprecated\>|\<private\>', 'once'));
    #files_with_tests = files_with_tests(weed_idx);
    #weed_idx = cellfun (@isempty, regexp (files_with_no_tests, '\<deprecated\>|\<private\>', 'once'));
    #files_with_no_tests = files_with_no_tests(weed_idx);

    report_files_with_no_tests (files_with_tests, files_with_no_tests, ".m");
    printf("\n");
    printf (list_in_columns (files_with_no_tests, 80));
    %puts ("\nPlease help improve Octave by contributing tests for\n");
    %puts ("these files (see the list in the file fntests.log).\n\n");

    anyfail = nfail > 0;

    page_screen_output (pso);
    warning (warn_state.state, "quiet");
  catch
    page_screen_output (pso);
    warning (warn_state.state, "quiet");
    disp (lasterr ());
  end_try_catch
endfunction


function print_test_file_name (nm)
  filler = repmat (".", 1, 50-length (nm));
  printf ("  %s %s", nm, filler);
endfunction


function print_pass_fail (p, n, xf, sk)
  if ((n + sk) > 0)
    printf (" PASS %3d/%-3d", p, n);
    nfail = n - p - xf;
    if (nfail > 0)
      printf (" \033[1;40;31m%s %d\033[m", "FAIL", nfail);
    endif
    if (sk > 0)
      printf (" \033[1;40;33m%s %d", "SKIP", sk);
    endif
    if (xf > 0)
      printf (" \033[1;40;33m%s %d\033[m", "XFAIL", xf);
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
