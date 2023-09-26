function im_filtered = half_gabor(im_in, window_size, theta, sigma, lambda, gamma, direction)
%HALF_GABOR Filter an image with an half-Gabor filter.
% Inputs
%           - im_in         the image to filter
%           - window_size   the size of the half-Gabor filter
%           - theta         the direction of the filter (in radiants)
%           - sigma         the width of the filter
%           - lambda        a parameter of the cosine
%           - gamma         the anisotropy parameter
%           - direction     the side of the half of the Gabor filter to
%                           keep
% Output
%           - im_filtered   the filtered image

half_size = ceil(window_size/2);

% Create the half-Gabor filter
one_to_taille_ligne = transpose(1:window_size)*ones(1, window_size);
x = (one_to_taille_ligne - half_size)*cos(theta) + (one_to_taille_ligne' - half_size)*sin(theta);
y = (one_to_taille_ligne' - half_size)*cos(theta) - (one_to_taille_ligne - half_size)*sin(theta);
gabor = (direction*x >= 0) .* cos(x*pi/(sqrt(2)*sigma*lambda)).*exp(-(x.^2 + gamma^2*y.^2)/(2*sigma^2));
% gabor = cos(x*pi/(sqrt(2)*sigma*lambda)).*exp(-(x.^2 + gamma^2*y.^2)/(2*sigma^2));


% Normalize the filter
gabor_positive = gabor > 0;
gabor_negative = gabor < 0;
sumplus = sum(gabor(gabor_positive));    % Sum the positive components
summinus = -sum(gabor(gabor_negative));  % Sum the negative components
gabor(gabor_positive) = gabor(gabor_positive)/(2*sumplus);
gabor(gabor_negative) = gabor(gabor_negative)/(2*summinus);
im_filtered = conv2(im_in,gabor,'same');

%% Uncomment if you want to see/sage the filter
% figure, imshow(imadjust(gabor));
% imwrite(imadjust(gabor), 'half-gabor-positive.png');
% figure, imshow(im_filtered);

end
