function vessels = extract_vessels( filter_response, level_filter_low, level_filter_high )
%EXTRACT_VESSELS Vessels extraction from a filtered image
%   vessels = EXTRACT_VESSELS(filter_response) returns a binary mask
%   corresponding to the vessels. filter_response is typically an output of
%   a filter (Gabor, Frangi, ...) given by apply_filter.m. 
%   Please check extract_networks.m for a use case.

% Thresholding the filter response with otsu to remove the low responses of
% the filter (and rescaling to [0 1] just in case).
vessels = rescale01(filter_response);

if nargin < 2
    level_filter_low = graythresh(vessels);
end

if nargin < 3
    level_filter_high = min(0.9, 3*level_filter_low);
end

[~, vessels] = hysteresis3d(filter_response, level_filter_low, level_filter_high);
% figure, imshow(vessels);

%% 'Clean' the image a little bit.
size_holes_max = 2e3;       % maximal size of the holes to fill
size_small_objects = 500;  % maximal size of the noisy objects to remove

% Remove the small objects
vessels = bwareaopen(vessels, size_small_objects, 8);
% figure, imshow(vessels), title('small objects removed');

% Closing the image to fill small gaps
vessels = imclose(vessels, strel('disk', 5));
% figure, imshow(vessels), title('closed image');

% Fill the vessel holes
filled_vessels = imfill(vessels, 'holes');
% figure, imshow(filled), title('All holes filled');

% Look at the holes filled
holes = filled_vessels & ~vessels;
% figure, imshow(holes)
% title('Hole pixels identified')

% We do not want to fill too big holes, because they could correspond to
% vessel loops, for instance. So we consider the big holes by looking at
% connected components bigger than size_holes_max
bigholes = bwareaopen(holes, size_holes_max);
% figure, imshow(bigholes)
% title('Only the big holes')

% Extract the small holes.
smallholes = holes & ~bigholes;
% figure, imshow(smallholes)
% title('Only the small holes')

% Add the small holes to the vessels.
vessels = vessels | smallholes;
% figure, imshow(new)
% title('Small holes filled')

% % Opening the image to remove some noise. Note : In the end I'm not doing
% % it because it may remove some 'dead-end' vessels and cut some of thin
% % vessels. Uncomment this part if you still want to perform the opening.
% vessels = imopen(vessels, strel('disk', 1));
% % figure, imshow(vessels), title('opened image');
% % Remove the residual objects left by the previous opening
% vessels = bwareaopen(vessels, size_small_objects, 8);
% % figure, imshow(new), title('small objects removed');

end