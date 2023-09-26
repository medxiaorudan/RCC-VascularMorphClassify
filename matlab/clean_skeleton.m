function [ skel ] = clean_skeleton( skel )
%SKELETON_ANALYSIS Clean a skeleton.
%   Input:
%           - SKEL : a skeleton
%   Outputs:
%           - SKEL : the cleaned skeleton
%           - BRANCHES : the branches of the skeleton (containing an
%           endpoint)
%           - N_E : number of endbranches
%           - N_J : number of junctions

size_small_branches = 500;
max_constant_values = 10;
skel = bwmorph(skel, 'spur');
size_skel = size(skel);

%% analyze the skeleton
% detect endpoints and junctions
[~, e_xy,j_xy] = anaskel(skel);

% to detect the branches, just remove the junctions and their 3x3 
% surrounding box.
idx_junctions = sub2ind(size_skel, j_xy(2, :), j_xy(1, :));
junctions = zeros(size_skel); 
junctions(idx_junctions) = 1;
junctions = logical(imdilate(junctions, ones(3)));

% get the branches. branches are just the skeleton minus the (dilated)
% junctions.
branches = skel;
branches(junctions) = 0;

% we want to extract ending branches, i.e. branches containing and endpoint
labelled_branches = bwlabel(branches);
idx_endpoints = sub2ind(size_skel, e_xy(2, :), e_xy(1, :));

label_endpoints = labelled_branches(idx_endpoints);

branches = ismember(labelled_branches, label_endpoints(label_endpoints > 0));

%% clean unwanted ending branches (i.e. too small or too straight)
cc_branches = bwconncomp(branches);

for idx_branch = 1:cc_branches.NumObjects
    pixel_list = cc_branches.PixelIdxList{idx_branch};
    
    % remove a branch if it's too small
    if numel(pixel_list) < size_small_branches
        skel(pixel_list) = 0;
    end
    
    % remove a branch if it's too straight (likely to be an artifact due to
    % the skeletonization). to do so, we want to find if there is more than
    % a certain number of consecutive equal values.
    
    % convert the linear idx given by bwconncomp to (i,j) idx
    [i_list, j_list] = ind2sub(size_skel, pixel_list);
    
    % first, we make a vector with zeros where i_list and j_list are
    % constant and 1 elsewhere. (it's some kind of grad)
    constant_vals_i = diff(i_list) > 0;
    constant_vals_j = diff(j_list) > 0;
    
    % then we find the idx where the gradiant goes from 1 to 0 and from 0
    % to 1.
    d_constant_vals_i = diff([1 constant_vals_i' 1]);
    d_constant_vals_j = diff([1 constant_vals_j' 1]);
    
    % and get the starting/ending idx for each set of consecutive 0s.
    start_index_i = find(d_constant_vals_i < 0);
    end_index_i = find(d_constant_vals_i > 0)-1;
    duration_i = end_index_i-start_index_i+1;
    
    % same for j's idx
    start_index_j = find(d_constant_vals_j < 0);
    end_index_j = find(d_constant_vals_j > 0)-1;
    duration_j = end_index_j-start_index_j+1;
    
    % then we remove the branches if they are too "straight"
    if any(duration_i > max_constant_values) || ...
            any(duration_j > max_constant_values)
        skel(pixel_list) = 0;
    end
end

% remove the very small isolated branches that appear here and there.
skel = bwareaopen(skel, 10);

end