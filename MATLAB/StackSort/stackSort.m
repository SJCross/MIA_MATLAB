% stack_in - The stack to order

% ref_stack - The stack to calculate the alignment for.  This should have a
% single channel and the same number of slices as stack_in.

% verbose - Boolean controlling if messages are displayed during execution.

function [stack] = stackSort(stack, ref_stack, verbose)
% The number of images in the stack
nIm = size(ref_stack,3);

% Creating forward order
if verbose
    javaMethod('println',java.lang.System.out,'[Sort stack] Sorting forward');
end

ord = zeros(nIm,1);
for i = 1:nIm
    idx = i+1:nIm;
    vals = zeros(1,numel(idx));
    
    for j = i+1:nIm
        corr_im = normxcorr2(ref_stack(:,:,i),ref_stack(:,:,j));
        vals(j-i) = max(corr_im(:));
    end
    
    max_pos = find(vals == max(vals),1);
    
    if max_pos == 1
        % If the best fit was the one immediately after the current frame
        % we assume the current frame was already in the optimal position
        ord(i) = i;
    elseif numel(max_pos) == 0
        % If no measurements were taken (i.e. the final frame), use the
        % current position
        ord(i) = i;
    else
        ord(i) = idx(max_pos);
    end
end

% Determining slice order based on minimum cost
pos = [1:nIm;ord]';
pos = sortrows(pos,2);
ref_stack = ref_stack(:,:,pos(:,1));
stack = stack(:,:,pos(:,1));

% Creating reverse order
ref_stack = flip(ref_stack,3);
stack = flip(stack,3);

if verbose
    javaMethod('println',java.lang.System.out,'[Sort stack] Sorting backward');
end

ord = zeros(nIm,1);
for i = 1:nIm
    idx = i+1:nIm;
    vals = zeros(1,numel(idx));
    
    for j = i+1:nIm
        corr_im = normxcorr2(ref_stack(:,:,i),ref_stack(:,:,j));
        vals(j-i) = max(corr_im(:));
    end
    
    max_pos = find(vals == max(vals),1);
    
    if max_pos == 1
        % If the best fit was the one immediately after the current frame
        % we assume the current frame was already in the optimal position
        ord(i) = i;
    elseif numel(max_pos) == 0
        % If no measurements were taken (i.e. the final frame), use the
        % current position
        ord(i) = i;
    else
        ord(i) = idx(max_pos);
    end
end

% Determining slice order based on minimum cost
pos = [1:nIm;pos_f]';
pos = sortrows(pos,2);

% Creating ordered stack
stack = stack(:,:,pos(:,1));
stack = flip(stack,3);

end