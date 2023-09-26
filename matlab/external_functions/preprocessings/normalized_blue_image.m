function [ im_bn ] = normalized_blue_image( im_in )
%NORMALIZED_BLUE_IMAGE compute the blue-normalized image of a RGB image
%   if r, g and b are the red, green and blue channels respectively, then
%   the normalized blue is defined as bn = b / (r + g + b) for each pixel
%   value.
%   Note that bn is between 0 and 1.

r = rescale01(im_in(:,:,1));
g = rescale01(im_in(:,:,2));
b = rescale01(im_in(:,:,3));

im_bn = b ./ ( r + g + b) ;

end

