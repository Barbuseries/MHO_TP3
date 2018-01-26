function export = Crossover
  export.singlePoint = @singlePoint;
end

function result = singlePoint(a, b, l)
  %% NOTE/FIXME: This assumes the crossover point is the same for all
  %% variables. If this is not the case, change '1' to be the number
  %% of variables and remove upper and lower multiplication by
  %% ones(size(a)) (see NOTE below).
  points = randi(l - 1, size(a)(1), 1); %% Find single point (for all individuals)
  max_val = 2**l - 1;

  %% NOTE: To split and merge as simply as possible, this compute the
  %% flags associted to the left and right parts of the binary
  %% representation (upper and lower).
  %% Given a point p, if we are computing the right part (lower),
  %% every bit after the point must be one.
  %% So, we take the decimal value at p (2 ** p => 0...010...0) and
  %% substract 1 (=> 0...001...1).
  %% To get the left part, we take the maximum value (all ones), and
  %% remove the previous flag: only ones before p (included) will
  %% remain.
  lower_flags = (2 .** points) - 1;
  upper_flags = max_val - lower_flags;

  %% NOTE: This is to use array application of bit functions, so I do
  %% not have to manually create a loop (which is / should be / most
  %% of the time is slower).
  upper_flags = upper_flags .* ones(size(a));
  lower_flags = lower_flags .* ones(size(a));

  result = make_children(a, b, upper_flags, lower_flags);
end

%% TODO: Find a better name.
function result = make_children(a, b, u, l)
  result = [ bitor(bitand(a,u), bitand(b, l)), bitor(bitand(b,u), bitand(a, l)) ];
end
