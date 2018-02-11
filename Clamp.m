function Clamp
								%CLAMP All clamp functions.
								%
								% default
								% fancy
								%
								% See also CLAMP>DEFAULT, CLAMP>FANCY
  
  global CLAMP;

  CLAMP.default = @default;
  CLAMP.fancy = @fancy;
end

function result = default(val, lowest, biggest)
  %% TODO: Doc...
  
  result = max(min(val, biggest), lowest);
end

%% NOTE: Btw, this fails if val is too low or too high.
function result = fancy(val, lowest, biggest)
  %% TODO: Doc...
  
  below = val < lowest;
  above = val > biggest;
  correct =  ~below & ~above;

  result = val .* correct + (2 * lowest - val) .* below + (2 * biggest - val) .* above;
end
