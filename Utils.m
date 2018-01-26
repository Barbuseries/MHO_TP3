function export = Utils
  export.shuffle = @shuffle;
  export.linspacea = @linspacea;
  export.reduce = @reduce;
end

function result = shuffle(a)
  new_order = randperm(length(a));
  result = a(new_order);
end

function result = linspacea(a, n)
  result = linspace(a(1), a(2), n);
end

function result = reduce(fn, a, v)
  for i  = a
	v = fn(v, i);
  end
  
  result = v;
end
