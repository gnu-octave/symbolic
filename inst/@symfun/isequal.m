function t = isequal(x, y)

  if (isa (x, 'symfun'))
    x = x.symbol;
  end
  if (isa (y, 'symfun'))
    y = y.symbol;
  end

  t = isequal(x, y);
end