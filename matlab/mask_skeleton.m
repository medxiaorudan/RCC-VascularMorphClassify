clear all;
close all;
clc;

% Ignoring the 'image is too big to fit on screen' warnings not to be
% flooded.
warning off images:initSize:adjustingMag

% Get the current file path and add the external
% functions to the matlab path so they can be used in this script.
[pathstr, name, ext] = fileparts(mfilename('D:/test_vascular_mask/mask_skeleton.m'));
addpath(genpath(pathstr));
%%
% main_histo_data = [pathstr 'D:/test_vascular_mask/pRCC'];
% dir_names = {'0','1','6','7','8'};
% n_dir = numel(dir_names);
% type = 'mask';
%%
main_histo_data = [pathstr 'D:/Doctoral_Programs/假期要做的mask/francesco_new_mask/pre_pRCC'];
dir_names = {'20','24'};
n_dir = numel(dir_names);

for i_dir = 1:n_dir
    case_folder = [main_histo_data, '/', dir_names{i_dir},'/','tumor'];
    list_annotation = dir(case_folder);
    n_annotation = length(list_annotation);
    for idx_annotation = 1: n_annotation
        image_list = dir([case_folder,'/',list_annotation(idx_annotation).name,'/mask/*.png']);
        n_images = length(image_list);
        for idx_image = 1:n_images
            fprintf('Processing image %d/%d... ', idx_image, n_images);
            mask_image_name = image_list(idx_image).name;
            image_mask_path = [case_folder,'/',list_annotation(idx_annotation).name, '/mask/', mask_image_name];
            img_mask = imread(image_mask_path);
            I = rgb2gray(img_mask);
            bw1=imbinarize(I,0.01);
            se1=strel('disk',5);
            A1=imerode(bw1,se1);
            out = bwskel(A1);
            imwrite(out, [case_folder,'/',list_annotation(idx_annotation).name,'/skeletons/skeleton_' mask_image_name]);
            fprintf('Done!\n');
        end
    end
end
%%
% for i_dir = 1:n_dir
%     case_folder = [main_histo_data, '/', dir_names{i_dir},'/',type];
%     image_list = dir([case_folder,'/', '*.png']);
%     n_images = length(image_list);
%     fprintf('total image: %d', n_images);
% %     for idx_image = 1 : n_images
%         fprintf('Processing image %d/%d... ', idx_image, n_images);
%         mask_image_name = image_list(idx_image).name;
%         image_mask_path = [case_folder,'/', mask_image_name];
%         img_mask = imread(image_mask_path);
%         I = rgb2gray(img_mask);
%         bw1=imbinarize(I,0.01);
%         se1=strel('disk',5);
%         A1=imerode(bw1,se1);
%         out = bwskel(A1);
%         imwrite(out, [main_histo_data, '/', dir_names{i_dir},'/skeletons/skeleton_' mask_image_name]);
%         fprintf('Done!\n');
%     end
% end
