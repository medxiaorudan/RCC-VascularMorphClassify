function bestNdx=mykmeans(X,k,nReplicates,maxIterations)
%
% function bestNdx=mykmeans(X,k,nReplicates,maxIterations)
%
% Partitions the points in the data matrix X into k clusters. This
% function behaves much like the stats/kmeans from MATLAB's
% Statitics toolbox called as follows:
%   bestNdx = kmeans(X,k,'Distance','cosine',...
%                    'Replicates',nReplicates,'MaxIter',maxIterations)
% 
% Inputs:
% X    - n by p data matrix, with one row per point.
% k    - desired number of partitions
% nReplicates - number of repetion for the clustering algorithm 
%       (optional input, defaults to 1)
% maxIterations - maximum number of iterations for the k-means algorithm
%           (per repetition)
% 
% Outputs:
% ndx  - n-vector with the cluster index for every node 
%       (indices from 1 to k)
% Pi   - Projection matrix [see Technical report
% cost - cost of the partition (sum of broken edges)
%
% Copyright (c) 2006, Joao Hespanha
% All rights reserved.

% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions
% are met:
%    * Redistributions of source code must retain the above copyright
%    notice, this list of conditions and the following disclaimer.
%
%    * Redistributions in binary form must reproduce the above
%    copyright notice, this list of conditions and the following
%    disclaimer in the documentation and/or other materials provided
%    with the distribution.
% 
%    * Neither the name of the <ORGANIZATION> nor the names of its
%    contributors may be used to endorse or promote products derived
%    from this software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
% "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
% LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
% FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
% COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
% INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
% BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
% LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
% LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
% ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.

% Modification history:
%
% October 21, 2006
% Created and GNU GPL added

if nargin<4,
  maxIterations=100;
end
if nargin<3,
  nReplicates=1;  
end
    
nPoints=size(X,1);
if nPoints<=k, 
  bestNdx=1:nPoints;
  return
end

% normalize vectors so that inner product is a distance measure
normX=sqrt(sum(X.^2,2));
X=X./(normX*ones(1,size(X,2)));
bestInnerProd=0; % best distance so far

for rep=1:nReplicates

  % random sample for the centroids
  ndx = randperm(size(X,1));
  centroids=X(ndx(1:k),:);
  
  lastNdx=zeros(nPoints,1);
  
  for iter=1:maxIterations
    InnerProd=X*centroids'; % use inner product as distance
    [maxInnerProd,ndx]=max(InnerProd,[],2);  % find 
    if ndx==lastNdx,
      break;          % stop the iteration
    else
      lastNdx=ndx;      
    end
    for i=1:k
      j=find(ndx==i);
      if isempty(j)     
	error('mykmeans: empty cluster')
      end
      centroids(i,:)=mean(X(j,:),1);
      centroids(i,:)=centroids(i,:)/norm(centroids(i,:)); % normalize centroids
    end
  end
  if sum(maxInnerProd)>bestInnerProd
    bestNdx=ndx;
    bestInnerProd=sum(maxInnerProd);
  end

end % for rep

