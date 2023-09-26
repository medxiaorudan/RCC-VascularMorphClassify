function filter_response = apply_filter( filter_input, method, widths, window_size )
%APPLY_FILTER Apply a filter to an image
%   Detailed explanation goes here

switch method
    
    case 'modified gabor'
        
        % initializing a few parameters
        filter_response = zeros(size(filter_input));
        gamma_gabor = 2.5; % you may want to change it. 5 seems to do the job quite well
        
        for sigma = widths
            filter_response = max(filter_response, detecRoad(filter_input, sigma, gamma_gabor, window_size));
        end
        
        
    case 'frangi'
        
        sigmas = [widths(1) widths(end)];
        scale_ratio = widths(2) - widths(1);
        % Frangi options
        options = struct('FrangiScaleRange', sigmas, 'FrangiScaleRatio', scale_ratio, ...
            'FrangiBetaOne', 1, 'FrangiBetaTwo', 1, 'verbose', true, 'BlackWhite', false);
        filter_input = imadjust(filter_input);
        filter_response = FrangiFilter2D(filter_input, options);
        
        
    case 'gabor'
        
        u = numel(widths);
        v = 16;
        gaborArray = gaborFilterBank(u, v, window_size, window_size);
        filter_response = zeros(size(filter_input));
        for i = 1:u
            for j = 1:v
                filter_response = max(filter_response, abs(conv2(filter_input,gaborArray{i,j},'same')));
            end
        end
        
        figure, imshow(imadjust(filter_response));
        
        
    otherwise
        warning('Wrong method input, please chose either ''modified gabor'' or ''frangi''');
        
end

end

