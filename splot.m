## -*- texinfo -*-
## @deftypefn {Function File} splot(@var{f},@var{x},@var{range})
## Plot a symbolic function f(x) over range.
## @end deftypefn

function splot(expression,symbol,range)
  ## we should be a little smarter about this
  t = linspace(min(range),max(range),400);
  x = zeros(size(t));
  j = 1;
  for i = t
    x(j) = to_double(subs(expression,symbol,vpa(t(j))));
    j++;
  endfor

  plot(t,x);
endfunction
