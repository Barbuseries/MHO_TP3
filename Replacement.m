function Replacement
  global REPLACEMENT;

  REPLACEMENT.none = [];
  REPLACEMENT.value = @value;
end

function result = value(fitness)
  [~, result] = sort(fitness);
end
