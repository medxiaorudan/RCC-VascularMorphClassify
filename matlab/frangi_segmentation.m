clear all;
close all;
clc;

% Ignoring the 'image is too big to fit on screen' warnings not to be
% flooded.
warning off images:initSize:adjustingMag

% Get the current file (extract_networks.m) path and add the external
% functions to the matlab path so they can be used in this script.
[pathstr, name, ext] = fileparts(mfilename('fullpath'));
addpath(genpath(pathstr)); % add all the external functions to current path

%% Loading the test image
main_histo_data = [pathstr '/../10.08.2014'];
% path to image : chose the image you want to work on. You may want to
% change some parameters depending on the image.
% case_folder = [main_histo_data,'/hp14.1993']; % ccrcc
% case_folder = [main_histo_data,'/hp14.5347']; % ccrcc greffé
% case_folder = [main_histo_data,'/hp14.64']; % ccrcc meta
case_folder = [main_histo_data,'/hp14.1749']; % ?
% case_folder = [main_histo_data,'/hp10.9650_1']; % pap
% case_folder = [main_histo_data,'/hp10.9650_2']; % pap
% case_folder = [main_histo_data,'/hp14.9700_1';]; % pap
% case_folder = [main_histo_data,'/hp14.9700_2';]; % pap
% case_folder = [main_histo_data,'/ha13.3003']; % ?
% case_folder = [main_histo_data,'/hp14.5794';]; % biopsy
% case_folder = [main_histo_data,'/hp14.5794_2';]; % biopsy
% case_folder = [main_histo_data,'/hp14.5794_3';]; % biopsy
% case_folder = [main_histo_data,'/hp14.5794_4';]; % biopsy

path_image = [case_folder,'/level0_crop.png'];
window_size = 25; % size of the neighborhood window for the filters
% widths = 25:10:45; % same as above; the sigmas should be around the width of the vessels

tic
img = im2double(imread(path_image)); % load image
img = flipdim(flipdim(img,1),2); % flip dims to match the Leica viewer
% img = img(1:floor(end/2), floor(end/2):end, :); % just making the image smaller for faster computation
% img = img(1:floor(end/2), 1:floor(end/2), :); % just making the image smaller for faster computation

img1 = rescale01(img(:,:,1));
img2 = rescale01(img(:,:,2));
img3 = rescale01(img(:,:,3));
img = cat(3,img1,img2,img3);

figure, imshow(img), title('initial image');

[ im_c1, ~, ~ ] = invariant_colors( img );
filter_input = imadjust(im_c1);
% filter_input = rescale01(rgb2gray(img));
% filter_input(filter_input < graythresh(filter_input)) = 0;
% save([pathstr 'filter_input.mat'], 'filter_input');

% level_otsu = graythresh(filter_input)
% level_otsu = 0.65;
% filter_input(filter_input < level_otsu) = 0;

clear img img1 img2 img3 im_c1

opts = struct('FrangiScaleRange', [1 25], 'FrangiScaleRatio', 3, 'FrangiBetaOne', 1, 'FrangiBetaTwo', 0.05, 'verbose',true,'BlackWhite',false);

featureVector = frangiFeatures(filter_input, opts);

a = reshape(featureVector, [numel(filter_input(:)), numel(featureVector(:))/numel(filter_input(:))]);
% a1 = reshape(a(:, 1), size(filter_input));
% figure, imshow(a1);

% opts = statset('Display','final');
% 
% idx = kmeans(zscore(a), 2, 'replicates', 3, 'Options', opts);
% idx = reshape(idx(:, 1), size(filter_input));
% idx = idx - 1;
% unique(idx(:))
% 
% figure, imshow(idx);
% toc;


inputs = a';
clear a featureVector

% Create a Self-Organizing Map
dimension1 = 2;
dimension2 = 2;
net = selforgmap([dimension1 dimension2]);

% Train the Network
[net,tr] = train(net,inputs(:, 1:1000:end));

% Test the Network
outputs = net(inputs);
classes = vec2ind(outputs);
idx = reshape(classes(:), size(filter_input));
filter_output = 1 - rescale01(idx);
figure, imshow(filter_output);

input_skeletonization = extract_vessels(filter_output);
figure, imshow(input_skeletonization), title('vessels extracted');

toc;
