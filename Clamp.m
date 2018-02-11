function Clamp
  global CLAMP;

  CLAMP.default = @defaultClamp; %% None
  CLAMP.fancy = @fancyClamp; %% None
end

function result = defaultClamp(val, lowest, biggest)
  result = max(min(val, biggest), lowest);
end

%% NOTE: Btw, this fails if val is too low or too high.
function result = fancyClamp(val, lowest, biggest)
  below = val < lowest;
  above = val > biggest;
  correct =  ~below & ~above;

  result = val .* correct + (2 * lowest - val) .* below + (2 * biggest - val) .* above;
end
