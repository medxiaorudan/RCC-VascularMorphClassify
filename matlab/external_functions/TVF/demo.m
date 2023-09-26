function demo(file)
    if nargin < 1
        file = 'banana1.edge';
    end

    % Read in the dot edge file and turn it into a bitmask image
    T = read_dot_edge_file(file);
    [e1,e2,l1,l2] = convert_tensor_ev(T);
    subplot(2,2,1), imshow(l1);
    
    % Run the tensor voting framework
    T = find_features(l1,25);
    
    % Threshold un-important data that may create noise in the
    % output.
    [e1,e2,l1,l2] = convert_tensor_ev(T);
    z = l1-l2;
    l1(z<0.3) = 0;
    l2(z<0.3) = 0;
    T = convert_tensor_ev(e1,e2,l1,l2);
    subplot(2,2,2), imshow(l1-l2,'DisplayRange',[min(z(:)),max(z(:))]);
    
    % Run a local maxima algorithm on it to extract curves
    re = calc_ortho_extreme(T,15,pi/8);
    subplot(2,2,3), imshow(re);
end