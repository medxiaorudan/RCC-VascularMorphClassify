function feature_vector = halfGaborFeatures( im_in, sigmas, thetas, window_size, verbose )
%HALFFABORFEATURES Extract the half-Gabor features of an image
%   Inputs:
%           im_in       the input image on which you want to compute the
%                       features
%           sigmas      an array of the sigma values of the filter
%           thetas      an array of the theta values of the filter
%           window_size the size of the window
%

lambda = 4/3;
gamma = 1;

feature_vector = zeros([numel(im_in) numel(sigmas)*numel(thetas)]);
feature_id = 1;

for sigma = sigmas
    for theta = thetas          % for all the angles
        
        if verbose
            fprintf('Computing the half-Gabor response for sigma = %f and theta = %f...', sigma, theta);
        end
        
        first_half_response = half_gabor(im_in, window_size, theta, sigma, lambda, gamma, +1);%CentralRoad crea funcion gabor y comboluciona co dep, eso es lo que devuelve (A,B)
        second_half_response = half_gabor(im_in, window_size, theta, sigma, lambda, gamma, -1);%el 1,-1 es para el sentido como esta definido en paper
        
        feature_vector(:, feature_id) = min(first_half_response(:), second_half_response(:));
        
        
        feature_id = feature_id + 1;    % going for the next set of features
        
        if verbose
            fprintf(' Done!\n');
        end
    end
end

end
