function t = isequal(x, y)

  if (isa (x, 'symfun'))
    x = x.sym;
  end
  if (isa (y, 'symfun'))
    y = y.sym;
  end

  t = isequal(x, y);
end