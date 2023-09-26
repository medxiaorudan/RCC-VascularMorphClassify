function [ im_dab ] = image_dab( im_in )
%NORMALIZED_BLUE_IMAGE compute the blue-normalized image of a RGB image
%   if r, g and b are the red, green and blue channels respectively, then
%   the normalized blue is defined as bn = b / (r + g + b) for each pixel
%   value.
%   Note that bn is between 0 and 1.

min_val = 1/20;

r = rescale01(im_in(:,:,1));
b = rescale01(im_in(:,:,3));

im_dab = rescale01(b.^2 ./ max(r, min_val));
% figure, imshow(im_dab), title('DAB');
% figure, imhist(im_dab, 1000);
% max(im_dab(:))
end

