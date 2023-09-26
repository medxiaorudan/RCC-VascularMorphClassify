clear all;
close all;
clc;

% Ignoring the 'image is too big to fit on screen' warnings not to be
% flooded.
warning off images:initSize:adjustingMag

% Get the current file (extract_networks.m) path and add the external
% functions to the matlab path so they can be used in this script.
[pathstr, name, ext] = fileparts(mfilename('D:/Doctoral_Programs/RCC/rcc-1-alexis/overlay_graphs_on_images.m'));
addpath(genpath(pathstr)); % add all the external functions to current path

%% Loading the test image
main_histo_data = [pathstr 'D:/Doctoral_Programs/RCC/data'];
dir_names = {'0', '1', '2', '3', '4', '5', '6', '7', '8','9','10','11','12','13','14'};
n_dir = numel(dir_names);

tic;

for i_dir = 1:n_dir
    case_folder = [main_histo_data, '/', dir_names{i_dir}];
    list_images = dir([case_folder '/subimages_0.25/*.png']);
    n_images = length(list_images);
    
    for idx_image = 1:n_images    
        fprintf('Processing image %d/%d... ', idx_image, n_images);
        img_name = list_images(idx_image).name;
        image_path = [case_folder '/subimages_0.25/' img_name];
        img = rescale01(double(imread(image_path)));
        skeleton_path = [case_folder '/skeletons/skeleton_' img_name];
        if exist(skeleton_path, 'file')
%           figure, imshow(img);
            skeleton = imread(skeleton_path);
%           dilated_skel = imdilate(skeleton, ones(11));
%           ov = overlay(img, dilated_skel, [0 1 0]);
%           figure, imshow(ov);
        
            for i = 1:1
                skeleton = clean_skeleton(skeleton);
%             figure, imshow(ov);
            end
        end
        dilated_skel = imdilate(skeleton, ones(5));
        ov = overlay(img, dilated_skel, [0 1 0]);
        imwrite(ov, [case_folder '/overlays/overlay_' img_name]);
        fprintf('Done!\n');
    end
end