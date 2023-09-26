function [vox,n_idx] = pk_follow_link(skel,node,k,j,idx,cans)

vox = [];
n_idx = [];

% assign start node to first voxel
vox(1) = node(k).idx(j);

i=1;
isdone = false;
while(~isdone) % while no node reached
    i=i+1; % next voxel
    next_cand = find(cans(:,1)==idx,1);
    if(~isempty(next_cand))
        cand = cans(next_cand,2);
        if(cand==vox(i-1)) % switch direction
            cand = cans(next_cand,3);
        end;
        if(skel(cand)>1) % node found
            vox(i) = idx;
            vox(i+1) = cand; % first node
            n_idx = skel(cand)-1; % node #
            isdone = 1;
        else % next voxel
            vox(i) = idx;
            idx = cand;
        end;
    else
        vox(i) = idx;
        n_idx = -1;
        isdone = 1;
    end;
end;
