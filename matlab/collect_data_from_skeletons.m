clear all;
close all;
clc;

% Ignoring the 'image is too big to fit on screen' warnings not to be
% flooded.
warning off images:initSize:adjustingMag

% Get the current file path and add the external
% functions to the matlab path so they can be used in this script.
[pathstr, name, ext] = fileparts(mfilename('D:/Doctoral_Programs/RCC/rcc-1-alexis/collect_data_from_skeletons.m'));
addpath(genpath(pathstr));

%% Loading the image
main_histo_data = [pathstr 'D:/Doctoral_Programs/RCC/data/'];
dir_names = { '0','8','9','10','11','12','14'};
n_dir = numel(dir_names);

tic;

for i_dir = 1:n_dir
    case_folder = [main_histo_data, '/', dir_names{i_dir}];
    list_images = dir([case_folder '/subimages_0.25/*.png']);
    n_images = length(list_images);
    s = struct;
	s.n_endpoints = 0;
	s.n_junctions = 0;
	s.end_branches_lengths = [];
	s.regular_branches_lengths = [];
	s.mean_branches_lengths = [];

    for idx_image = 1:n_images
        fprintf('Processing image %d/%d... ', idx_image, n_images);
		img_name = list_images(idx_image).name;
		skel_path = [case_folder '/skeletons/skeleton_' img_name];
		if exist(skel_path, 'file')
			% read the skeleton
			skel = imread(skel_path);
        
			% clean it before analyzing it
			skel = clean_skeleton(skel);
        
			% analyze the skeleton
			[ end_branches_lengths, regular_branches_lengths, n_e, n_j ] = skeleton_analysis( skel );
        
			% update the structure
			s.n_endpoints = s.n_endpoints + n_e;
			s.n_junctions = s.n_junctions + n_j;
			s.mean_branches_lengths = [mean([end_branches_lengths regular_branches_lengths]), s.mean_branches_lengths];
			s.end_branches_lengths = [s.end_branches_lengths, end_branches_lengths];
			s.regular_branches_lengths = [s.regular_branches_lengths regular_branches_lengths];
		end
		fprintf('Done!\n');
    end
	figure;
	subplot(2, 3, 1); hist(s.end_branches_lengths, 100); title('end branches lengths');
	subplot(2, 3, 2); hist(s.regular_branches_lengths, 100); title('regular branches lengths');
	subplot(2, 3, 3); hist([s.end_branches_lengths s.regular_branches_lengths], 100); title('all branches lengths');
	subplot(2, 3, 4); hist(log10(1 + s.end_branches_lengths)); title('end branches lengths (log)');
	subplot(2, 3, 5); hist(log10(1 + s.regular_branches_lengths)); title('regular branches lengths (log)');
	subplot(2, 3, 6); hist(log10(1 + [s.end_branches_lengths s.regular_branches_lengths])); title('all branches lengths (log)');

	% figure;
	% hist(s.mean_branches_lengths, 100); title('average branches lengths per image');

	mean(s.regular_branches_lengths)
	mean(s.end_branches_lengths)
	s.n_junctions
	s.n_endpoints
    
	% save feature data
    feature_path=[main_histo_data,dir_names{i_dir}, '/features.txt'];
	fid=fopen(feature_path,'a+');
	%fprintf(fid,'%s \t %s \t \n%s \t %d \t \n%s \t %d \t \n%s \t %d \t \n%s \t %d \t \n%s \t %d \t \n%s \t %d \t \n', 'ID',dir_names{i_dir},'NE',s.n_endpoints,'NJ',s.n_junctions,'LE',mean(s.end_branches_lengths),'LJ',mean(s.regular_branches_lengths),'NE/NJ',s.n_endpoints/s.n_junctions,'LE/LJ',mean(s.end_branches_lengths)/mean(s.regular_branches_lengths));
	fprintf(fid,'%s \t %s \t %s \t %s \t %s \t %s \t %s \t \n%d \t %d \t %d \t %d \t %d \t %d \t %d \t \n', 'ID','NE','NJ','LE','LJ','NE/NJ','LE/LJ',dir_names{i_dir},s.n_endpoints,s.n_junctions,mean(s.end_branches_lengths),mean(s.regular_branches_lengths),s.n_endpoints/s.n_junctions,mean(s.end_branches_lengths)/mean(s.regular_branches_lengths));
	fclose(fid);
end

toc;
