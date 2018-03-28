function Mutation
  %MUTATION All mutation functions.
  
  global MUTATION;

  MUTATION.simpleInverse = @simpleInverse_;
  MUTATION.displace = @displace_;
  MUTATION.inverse = @inverse_;
  MUTATION.inserte = @inserte_;
  
  MUTATION.swap = @swap_;
  MUTATION.pop = @pop_;
  MUTATION.insert = @insert_;
end

function result = simpleInverse_(children, mutations)
  [~, len] = size(children);
    
  mutation_indices = find(mutations == 1);
  mutation_count = length(mutation_indices);

  random_start = randi(len, mutation_count, 1);
  
  %% A locus count of 1 would not do anything. Maybe it would be ok,
  %% but I _want_ something to happen.
  random_locus_count = randi(len - 2, mutation_count, 1) + 1;
  random_end = random_start + random_locus_count - 1;
  
  result = children;

  for i = 1:mutation_count
	index = mutation_indices(i);

	%% Start is always within bounds
	index_start = random_start(i);
	%% The sequence can wrap (start + locus_count > len)
	absolute_index_end = random_end(i);

	inv_sequence = absolute_index_end:-1:index_start;

	%% To make it easier to get the sequence
    repeated = [result(index, :), result(index, :)];
	inv_pattern = repeated(inv_sequence);

	%% If the sequence is completly within bounds (absolute_index_end
	%% <= len), second part is empty.
	%% Otherwhise, this takes care of the part between start and len,
	%% and second part corresponds to the wrapping.
	index_end = min(absolute_index_end, len);
    first_part = index_start:index_end;
	first_part_count = length(first_part);
    
    new_index_end= (absolute_index_end - len);
    second_part = 1:new_index_end;
	
	result(index, first_part) = inv_pattern(1:first_part_count);
	result(index, second_part) = inv_pattern((first_part_count+1):end);
  end
end

function result = displace_(children, mutations)
  [~, len] = size(children);
  
  mutation_indices = find(mutations == 1);
  mutation_count = length(mutation_indices);
  
  result =children;
  
  for i = 1:mutation_count
    index = mutation_indices(i);
    
    seg_lenght =  randi(len-1, 1);
    seg_start =  randi(len-seg_lenght, 1);
    seg_end = seg_start+seg_lenght;
    
    currentChildren = children(index,:);
    seg =currentChildren(seg_start:seg_end-1);
    
    p1 = currentChildren(1:seg_start-1);
    p2 = currentChildren(seg_end:end);
    
    children_without_seg = [p1 p2];
    
    seg_insertion_pos = randi(length(children_without_seg), 1);
    pa = children_without_seg(1:seg_insertion_pos);
    pb = children_without_seg(seg_insertion_pos+1:end);
    
    result(index, :) = [pa seg pb];
  end
end

function result = inverse_(children, mutations)
  [~, len] = size(children);

  mutation_indices = find(mutations == 1);
  mutation_count = length(mutation_indices);
  
  result =children;
  
  for i = 1:mutation_count
    index = mutation_indices(i);
    
    seg_lenght =  randi(len-1, 1);
    seg_start =  randi(len-seg_lenght, 1);
    seg_end = seg_start+seg_lenght;
    
    currentChildren = children(index,:);
    seg =currentChildren(seg_start:seg_end-1);
    %the only change with displacement_mutation
    seg =fliplr(seg);
    
    p1 = currentChildren(1:seg_start-1);
    p2 = currentChildren(seg_end:end);
    children_without_seg = [p1 p2];
    
    seg_insertion_pos = randi(length(children_without_seg), 1);
    pa = children_without_seg(1:seg_insertion_pos);
    pb = children_without_seg(seg_insertion_pos+1:end);
    
    result(index, :) = [pa seg pb];
  end
end

function result = inserte_(children, mutations)
  [~, len] = size(children);
  
  mutation_indices = find(mutations == 1);
  mutation_count = length(mutation_indices);
  
  result =children;
  
  for i = 1:mutation_count
    index = mutation_indices(i);
    
    element_pos = randi(len, 1);
    element = children(index,element_pos);
    
    popChildren = pop_(children(index,:), element_pos);
    new_element_pos = randi(len-1, 1);
    
    result(index, :) =insert_(popChildren, new_element_pos, element);
  end
end

function result = swap_(children, mutations)
  global UTILS;

  [N, len] = size(children);
  
  row_indices = find(mutations);
  
  columns_to_swap = UTILS.randUnique(len, length(row_indices), 2);

  indices = row_indices + (columns_to_swap - 1) * N;
  indices_rev = indices(:, end:-1:1);
  
  result = children;
  result(indices) = result(indices_rev);
end

function result = pop_(array, pos)
    pa = array(1:pos-1);
    pb = array(pos+1:end);
    result = [pa pb];
end

function result = insert_(array, pos, element)
    pa = array(1:pos);
    pb = array(pos+1:end);
    result = [pa element pb];
end
