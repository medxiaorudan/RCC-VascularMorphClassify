function [ im_pca1, im_pca2, im_pca3 ] = image_pixelwise_pca( im_in )
%NORMALIZED_BLUE_IMAGE compute the blue-normalized image of a RGB image
%   if r, g and b are the red, green and blue channels respectively, then
%   the normalized blue is defined as bn = b / (r + g + b) for each pixel
%   value.
%   Note that bn is between 0 and 1.

% min_val = 1e-10;

r = rescale01(im_in(:,:,1));
g = rescale01(im_in(:,:,2));
b = rescale01(im_in(:,:,3));

pixel_list = [r(:), g(:), b(:)];

[~, score] = pca(pixel_list);

% size(pca_coeffs)
% cumsum(latent) ./ sum(latent)
% size(score)

sz = size(r);

% Returning the images:
im_pca1 = rescale01(reshape(score(:, 1), sz));
im_pca2 = rescale01(reshape(score(:, 2), sz));
im_pca3 = rescale01(reshape(score(:, 3), sz));
end