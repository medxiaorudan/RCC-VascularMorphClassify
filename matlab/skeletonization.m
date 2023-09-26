clear all;
close all;
clc;

warning off images:initSize:adjustingMag % ignore the display warnings
[pathstr, name, ext] = fileparts(pwd());
addpath(genpath(pathstr)) % add all the external functions to current path

fprintf('Loading the image...\n');
load gabor_response.mat % load the initial image and the gabor response image
figure, imshow(initial_image), title('initial image');
figure, imshow(imadjust(gabor_response)), title('gabor response');  % show them

fprintf('Thresholding the image...\n');
level_otsu = graythresh(gabor_response); % threshold the image with otsu
thresholded_gabor_response = gabor_response > level_otsu;
figure, imshow(thresholded_gabor_response)
title('Thresholded Gabor response'); % show it

%% Filling the small holes of the images
fprintf('Removing small objects and filling the gaps...\n');

original = thresholded_gabor_response;
size_holes_max = 2e3;
size_small_objects = 2500;

original = bwareaopen(original, size_small_objects, 8);
% figure, imshow(original), title('small objects removed');

closed_image = imclose(original, strel('disk', 10));
% figure, imshow(closed_image), title('closed image');

% opened_image = imopen(closed_image, strel('disk', 3));
% figure, imshow(opened_image), title('opened image');
opened_image = closed_image;

new = bwareaopen(opened_image, size_small_objects, 8);
% figure, imshow(new), title('small objects removed');

original = new;

filled = imfill(original, 'holes');
% figure, imshow(filled)
% title('All holes filled');

holes = filled & ~original;
% figure, imshow(holes)
% title('Hole pixels identified')

bigholes = bwareaopen(holes, size_holes_max);
% figure, imshow(bigholes)
% title('Only the big holes')

smallholes = holes & ~bigholes;
% figure, imshow(smallholes)
% title('Only the small holes')

new = original | smallholes;
% figure, imshow(new)
% title('Small holes filled')

% open_image = imopen(new, strel('disk', 3));
% figure, imshow(open_image), title('closed image');

% break


imput_skeletonization = new;
figure, imshow(imput_skeletonization);
%% Try different methods to extract the skeleton of the gabor response
fprintf('Trying various methods to extract the skeleton...\n');

% matlab's bwmorph function to extract the skeleton
fprintf('bwmorph skel... ');
skel_gabor = bwmorph(imput_skeletonization,'skel', Inf);
figure, imshow(skel_gabor), title('bwmorph skel');

% % matlab's bwmorph function to thin the response
% fprintf('bwmorph thinning 10 iterations...');
% t_init = cputime;
% thinned_gabor_response_10 = bwmorph(thresholded_gabor_response, 'thin', 10);
% fprintf(' Done! Elapsed time: %4.2fs\n', cputime - t_init);
% figure, imshow(thinned_gabor_response_10), title('bwmorph thin 10');
% 
% fprintf('bwmorph thinning 50 iterations...');
% t_init = cputime;
% thinned_gabor_response_50 = bwmorph(thresholded_gabor_response, 'thin', 50);
% fprintf(' Done! Elapsed time: %4.2fs\n', cputime - t_init);
% figure, imshow(thinned_gabor_response_50), title('bwmorph thin 50');

fprintf('bwmorph thinning 100 iterations...');
t_init = cputime;
thinned_gabor_response = bwmorph(imput_skeletonization, 'thin', 'inf');
fprintf(' Done! Elapsed time: %4.2fs\n', cputime - t_init);
figure, imshow(thinned_gabor_response), title('bwmorph thin');

% voronoi's skeleton
fprintf('voronoi skeleton... ');
t_init = cputime;
voronoi_skel_gabor = voronoiSkel(imput_skeletonization);
fprintf(' Done! Elapsed time: %4.2fs\n', cputime - t_init);
figure, imshow(voronoi_skel_gabor), title('voronoi skel');

% % with spurring as pre-processing
% fprintf('spurring followed by voronoi skeleton...');
% t_init = cputime;
% voronoi_skel_spurred_gabor = voronoiSkel(bwmorph(thresholded_gabor_response, 'spur', 200));
% fprintf(' Done! Elapsed time: %4.2fs\n', cputime - t_init);
% figure, imshow(voronoi_skel_spurred_gabor), title('voronoi skel spur');

%% Post-processing: Spurring the skeleton with different sizes
input_spurring = thinned_gabor_response;


sizes_small_objects = 50;

for size_small_objects = sizes_small_objects
    
    fprintf('spurred voronoi skeleton (size %d)...', size_small_objects);
    t_init = cputime;
    input_spurring = bwmorph(input_spurring, 'spur', size_small_objects);
    input_spurring = bwareaopen(input_spurring, 25, 8);
    fprintf(' Done! Elapsed time: %4.2fs\n', cputime - t_init);
    figure, imshow(input_spurring), title(sprintf('voronoi skel spurred %i', size_small_objects));
    
end

% % trying iterative spurrings
% 
% n_iter = 5;
% size_small_objects = 50;
% 
% for i_iter = 1:n_iter
%     
%     fprintf('iteratively spurring voronoi skeleton (size %d, iteration %i)...', size_small_objects, i_iter);
%     t_init = cputime;
%     input_spurring = bwmorph(input_spurring, 'spur', size_small_objects);
%     input_spurring = bwareaopen(input_spurring, size_small_objects, 8);
%     fprintf(' Done! Elapsed time: %4.2fs\n', cputime - t_init);
%     figure, imshow(input_spurring); 
%     title(sprintf('voronoi skel spurred %i, iteration %i', size_small_objects, i_iter));
%     
% end