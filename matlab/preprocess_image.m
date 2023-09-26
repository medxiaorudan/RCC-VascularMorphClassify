function [ img_out ] = preprocess_image( img, show_image )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

eccentricity_max = .9;
size_big_object = 1500;
size_small_object = 200;
extent_max = 0.5;

% Rescaling each channel of the image between 0 and 1
img = im2double(img);
if sum(sum(sum(img))/(size(img,1)*size(img,2)))>2
	img = imadjust(img,[.3 .35 0; .9 .95 1],[]);
end
img1 = rescale01(img(:,:,1));
img2 = rescale01(img(:,:,2));
img3 = rescale01(img(:,:,3));
img = cat(3,img1,img2,img3);
%% Nuclei detection
% image used: hematoxylin (shows nuclei in black, so we use 1 - hematox to
% see the nuclei in white)
[ im_h ] = imadjust(1 - image_h( img ));


if show_image
	figure, imshow(img);
end

imwrite(img, 'input_img.png');

% classic procedure to detect small balls (i.e. nuclei)
se_open = strel('disk', 5);
open_img = imopen(im_h, se_open);
nuclei = open_img > .5;
se_close = strel('disk', 3);
nuclei = imclose(nuclei, se_close);

ball_props = regionprops(nuclei, 'Eccentricity', 'Area', 'PixelIdxList', 'Extent');

n_balls = numel(ball_props);
for idx_ball = 1:n_balls
	props = ball_props(idx_ball);

	if props.Area > size_big_object || ...
			props.Area < size_small_object || ...
			props.Eccentricity > eccentricity_max || ...
			props.Extent < extent_max
		nuclei(props.PixelIdxList) = 0;
	end
end

% ignore regular nuclei, just consider stacks of nuclei that are likely to
% appear in the vessels
% nuclei = ball & ~bwareaopen(ball, 750);

normalized_purple = (img1 + img3)./(2*sqrt(img1.^2 + img2.^2 + img3.^2));
network_input = imadjust(normalized_purple);
network_input(nuclei) = 0; % remove the nuclei 

if show_image
	figure,imshow(image_h( img ));
end

if show_image
	figure,imshow(im_h);
end


if show_image
	figure,imshow(normalized_purple);
end

if show_image
	figure, imshow(network_input);
end

level_filter_low = .65;
level_filter_high = .9;

[~, vessels] = hysteresis3d(network_input, level_filter_low, level_filter_high);
if show_image
	figure, imshow(vessels.*network_input);
end
bw = imclose(vessels, se_close);
if show_image
	figure, imshow(bw);
end

cc = bwconncomp(bw);
graindata = regionprops(cc,'basic');
grain_areas = [graindata.Area]; 
if show_image
	figure, hist(grain_areas,200);
end

bw = bwareaopen(bw, 7500);
if show_image
	figure, imshow(bw);
end
img_out = bw.*network_input;

%% optional part, just saving a few images for illustration purpose
% im_e = image_e(img);
% [ im_c1, im_c2, im_c3 ] = invariant_colors( img );
% [ im_pca1, im_pca2, im_pca3 ] = image_pixelwise_pca( img );
% imwrite(img, 'level0-initial.png');
% imwrite(imadjust(img_out), 'hysteresis-cleaned.png');
% imwrite(imadjust(network_input.*vessels), 'hysteresis-output.png');
% imwrite(imadjust(network_input), 'hysteresis-input-purple.png');
% imwrite(network_input, 'network-input-final.png');
% imwrite(imadjust(img1), 'level0-red.png');
% imwrite(imadjust(img2), 'level0-green.png');
% imwrite(imadjust(img3), 'level0-blue.png');
% imwrite(imadjust(im_c1), 'level0-c1.png');
% imwrite(imadjust(im_c2), 'level0-c2.png');
% imwrite(imadjust(im_c3), 'level0-c3.png');
% imwrite(imadjust(normalized_purple), 'level0-purple.png');
% imwrite(imadjust(im_e), 'level0-eosin.png');
% imwrite(imadjust(im_h), 'level0-hematoxylin.png');
% imwrite(imadjust(im_pca1), 'level0-pca1.png');
% imwrite(imadjust(im_pca2), 'level0-pca2.png');
% imwrite(imadjust(im_pca3), 'level0-pca3.png');
% imwrite(imadjust(network_input), 'network-input.png');
% ov = overlay_binary(img,nuclei,true);
% imwrite(ov, 'nuclei-segmentation-final.png');
end

