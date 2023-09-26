function [ im_e ] = image_e( im_in )
%NORMALIZED_BLUE_IMAGE compute the blue-normalized image of a RGB image
%   if r, g and b are the red, green and blue channels respectively, then
%   the normalized blue is defined as bn = b / (r + g + b) for each pixel
%   value.
%   Note that bn is between 0 and 1.

min_val = 1/20;

r = rescale01(im_in(:,:,1));
g = rescale01(im_in(:,:,2));

im_e = rescale01(g ./ max(r, min_val));
% figure, imshow(im_e), title('eosine');
% figure, imhist(im_e, 1000);
end