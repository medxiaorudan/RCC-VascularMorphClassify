% Skel2Graph3D: calculate the network graph of a 3D skeleton
%
% This function converts a 3D binary voxel skeleton into a network graph
% described by nodes and edges.
%
% The input is a 3D binary image containing a one-dimensional voxel
% skeleton, generated e.g. using the "Skeleton3D" thinning function
% available on MFEX. The output is the adjacency matrix of the graph,
% and the nodes and links of the network as MATLAB structure.
%
% Note that the boundary layer of the skeleton is converted to zeros before
% calculating the graph.
%
% Usage:
%
% [A,node,link] = Skel2Graph(skel,THR),
%
% where "skel" is the input 3D binary image, A is the adjacency matrix,
% and node/link are the structures describing node and link properties.
%
% The only parameter "THR" is a threshold for the minimum length of
% branches (edges that do not end at another node), to filter out 
% skeletonization artifacts.
%
% A second function, "Graph2Skel3D.m", converts the network graph back
% into a cleaned-up voxel skeleton image.
%
% An example of how to use these functions is given in the script
% "Test_Skel2Graph3D.m", including a test image. In this example, it is 
% also demonstrated how to iteratively combine both conversion functions
% in order to obtain a completely cleaned skeleton graph.
%
% Any comments, corrections or suggestions are highly welcome.
% If you include this in your own work, please cite our publicaton [1].
%
% Philip Kollmannsberger 09/2013
% philipk@gmx.net
%
% [1] Kerschnitzki, Kollmannsberger et al.,
% "Architecture of the osteocyte network correlates with bone material quality."
% Journal of Bone and Mineral Research, 28(8):1837-1845, 2013.
%
%
function [A,node,link] = Skel2Graph3D(skel,THR)

% image dimensions
w=size(skel,1);
l=size(skel,2);
h=size(skel,3);

% change volume boundaries to zero
skel(1,:,:)=0;
skel(:,1,:)=0;
skel(:,:,1)=0;
skel(end,:,:)=0;
skel(:,end,:)=0;
skel(:,:,end)=0;

% need this for labeling nodes etc.
skel2 = uint16(skel);

% all foreground voxels
list_canal=find(skel);

% 26-nh of all canal voxels
nh = logical(pk_get_nh(skel,list_canal));

% 26-nh indices of all canal voxels
nhi = pk_get_nh_idx(skel,list_canal);

% # of 26-nb of each skel voxel + 1
sum_nh = sum(logical(nh),2);

% all canal voxels with >2 nb are nodes
nodes = list_canal(sum_nh>3);

% all canal voxels with exactly 2 nb
cans = list_canal(sum_nh==3);

% Nx3 matrix with the 2 nb of each canal voxel
can_nh_idx = pk_get_nh_idx(skel,cans);
can_nh = pk_get_nh(skel,cans);

% remove center of 3x3 cube
can_nh_idx(:,14)=[];
can_nh(:,14)=[];

% keep only the two existing foreground voxels
can_nb = sort(logical(can_nh).*can_nh_idx,2);

% remove zeros
can_nb(:,1:end-2) = [];

% add neighbours to canalicular voxel list (this might include nodes)
cans = [cans can_nb];

% group clusters of node voxels to nodes
node=[];
link=[];

tmp=false(w,l,h);
tmp(nodes)=1;
cc2=bwconncomp(tmp); % number of unique nodes

% create node structure
for i=1:cc2.NumObjects
    node(i).idx = cc2.PixelIdxList{i};
    node(i).links = [];
    node(i).conn = [];
    [x, y, z]=ind2sub([w l h],node(i).idx);
    node(i).comx = mean(x);
    node(i).comy = mean(y);
    node(i).comz = mean(z);
    
    % assign index to node voxels
    skel2(node(i).idx) = i+1;
end;

l_idx = 1;

% visit all nodes
for i=1:length(node)
    
    % find all canal vox in nb of all node idx
    link_idx = find(ismember(nhi(:,14),node(i).idx));
    
    for j=1:length(link_idx)
        % visit all voxels of this node
        
        % all potential unvisited links emanating from this voxel
        link_cands = nhi(link_idx(j),nh(link_idx(j),:)==1);
        link_cands = link_cands(skel2(link_cands)==1);
        
        for k=1:length(link_cands)
            [vox,n_idx] = pk_follow_link(skel2,node,i,j,link_cands(k),cans);
            skel2(vox(2:end-1))=0;
            if(n_idx<0) % for endpoints, also remove last voxel
                skel2(vox(end))=0;
            end; % only large branches or non-loops
            if((n_idx<0 && length(vox)>THR) || (i~=n_idx && n_idx>0))
                link(l_idx).n1 = i;
                link(l_idx).n2 = n_idx; % node number
                link(l_idx).point = vox;
                node(i).links = [node(i).links, l_idx];
                node(i).conn = [node(i).conn, n_idx];
                if(n_idx>0)
                    node(n_idx).links = [node(n_idx).links, l_idx];
                    node(n_idx).conn = [node(n_idx).conn, i];
                end;
                l_idx = l_idx + 1;
            end;
        end;
    end;
end;

% create adjacency matrix
A = zeros(length(node));

for i=1:length(node)
    idx1=find(node(i).conn>0);
    idx2=find(node(i).links>0);
    idx=intersect(idx1,idx2);
    for j=1:length(idx)
        if(i==link(node(i).links(idx(j))).n1)
            A(i,link(node(i).links(idx(j))).n2)=length(link(node(i).links(idx(j))).point);
            A(link(node(i).links(idx(j))).n2,i)=length(link(node(i).links(idx(j))).point);
        end;
        if(i==link(node(i).links(idx(j))).n2)
            A(i,link(node(i).links(idx(j))).n1)=length(link(node(i).links(idx(j))).point);
            A(link(node(i).links(idx(j))).n1,i)=length(link(node(i).links(idx(j))).point);
        end;
    end;
end;


