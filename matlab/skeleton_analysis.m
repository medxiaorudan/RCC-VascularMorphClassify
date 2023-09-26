function [ end_branches_lengths, regular_branches_lengths, n_e, n_j ] = skeleton_analysis( skel )
%SKELETON_ANALYSIS Perform an analysis and clean a skeleton.
%   Input:
%           - SKEL : a skeleton
%   Outputs:
%           - SKEL : the cleaned skeleton
%           - BRANCHES : the branches of the skeleton (containing an
%           endpoint)
%           - N_E : number of endbranches
%           - N_J : number of junctions
%           - 

skel = bwmorph(skel, 'spur');
size_skel = size(skel);

%% analyze the skeleton
% detect endpoints and junctions
[~, e_xy,j_xy] = anaskel(skel);
n_e = size(e_xy, 2);
n_j = size(j_xy, 2);

% to detect the branches, just remove the junctions and their 3x3 
% surrounding box.
idx_junctions = sub2ind(size_skel, j_xy(2, :), j_xy(1, :));
junctions = zeros(size_skel); 
junctions(idx_junctions) = 1;
junctions = logical(imdilate(junctions, ones(3)));

% get the branches. branches are just the skeleton minus the (dilated)
% junctions.
end_branches = skel;
end_branches(junctions) = 0;

% we want to extract ending branches, i.e. branches containing and endpoint
labelled_branches = bwlabel(end_branches); % detect all the branches and give them a unique label

idx_endpoints = sub2ind(size_skel, e_xy(2, :), e_xy(1, :)); 
label_endpoints = labelled_branches(idx_endpoints); % find labels of branches containing an endpoint

end_branches = ismember(labelled_branches, label_endpoints(label_endpoints > 0)); % get the resulting ending branches

% now we do the same with the regular branches (i.e. branches which are not
% ending branches). 
regular_branches = skel - end_branches; % remove end branches from the skeleton
regular_branches(junctions) = 0; % also remove the junctions to get branches

%% get lengths of both type of branches
% end branches
cc_end = bwconncomp(end_branches);
end_branches_lengths = cellfun(@numel,cc_end.PixelIdxList);
% regular branches
cc_regular = bwconncomp(regular_branches); 
regular_branches_lengths = cellfun(@numel,cc_regular.PixelIdxList);

end