clear all;
close all;
clc;

% Ignoring the 'image is too big to fit on screen' warnings not to be
% flooded.
warning off images:initSize:adjustingMag
show_images = false;
%show_images = true;

% Get the current file (extract_networks.m) path and add the external
% functions to the matlab path so they can be used in this script.
[pathstr, name, ext] = fileparts(mfilename('D:/Doctoral_Programs/RCC/rcc-1-alexis/extract_networks.m'));
addpath(genpath(pathstr)); % add all the external functions to current path

%% Loading the test image
main_histo_data = [pathstr 'D:/Doctoral_Programs/RCC/data'];
dir_names = {'0','8','9','10','11','12','14'};
n_dir = numel(dir_names);

tic;

for i_dir = 1:n_dir
    case_folder = [main_histo_data, '/', dir_names{i_dir}];
    list_images = dir([case_folder '/subimages_0.25/*.png']);
    n_images = length(list_images);
    
    for idx_image = 1:n_images
        fprintf('Processing image %d/%d... ', idx_image, n_images);
        image_name = list_images(idx_image).name;
        image_path = [case_folder '/subimages_0.25/' image_name];
        img = imread(image_path);
        preprocessed_image = preprocess_image(img,show_images);
        skeleton = extract_network(preprocessed_image, show_images);
        imwrite(skeleton, [case_folder '/skeletons/skeleton_' image_name]);
        fprintf('Done!\n');
    end
end

toc;