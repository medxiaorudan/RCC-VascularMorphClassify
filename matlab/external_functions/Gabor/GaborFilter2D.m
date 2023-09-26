function [gabor_response] = GaborFilter2D(img,gaborArray)

% GABORFEATURES extracts the Gabor features of the image.
% It creates a column vector, consisting of the image's Gabor features.
% The feature vectors are normalized to zero mean and unit variance.
%
%
% Inputs:
%       img         :	Matrix of the input image 
%       gaborArray	:	Gabor filters bank created by the function gaborFilterBank
%       d1          :	The factor of downsampling along rows.
%                       d1 must be a factor of n if n is the number of rows in img.
%       d2          :	The factor of downsampling along columns.
%                       d2 must be a factor of m if m is the number of columns in img.
%               
% Output:
%       featureVector	:   A column vector with length (m*n*u*v)/(d1*d2). 
%                           This vector is the Gabor feature vector of an 
%                           m by n image. u is the number of scales and
%                           v is the number of orientations in 'gaborArray'.


if (nargin ~= 2)    % Check correct number of arguments
    error('Use correct number of input arguments!')
end

if size(img,3) == 3	% % Check if the input image is grayscale
    img = rgb2gray(img);
end

img = double(img);


%% Filtering

% Filter input image by each Gabor filter
[u,v] = size(gaborArray);
gabor_response = zeros(size(img));
for i = 1:u
    for j = 1:v
        gabor_response = max(gabor_response, abs(conv2(img,gaborArray{i,j},'same')));
    end
end


