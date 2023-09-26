function skel = extract_network( img, plot_images )


set_thresholds = true;
if set_thresholds % adapt the values to the data
    level_filter_low = 0.35; 
    level_filter_high = 0.8;
end

window_size = 50; % size of the neighborhood window for the filters
widths = 18:10:63; % same as above; the sigmas should be around the width of the vessels
% filtering method to extract the vessels. Chose either 'modified gabor',
% 'gabor' or 'frangi'
filter_method = 'modified gabor';
% skeletonization method. Chose either 'thinning', 'voronoi' or 'telea'
skeleton_method = 'thinning';

img = rescale01(im2double(img)); % load image

filter_response = apply_filter(img, filter_method, widths, window_size);
% imwrite(imadjust(filter_response), 'filter-response-modified-gabor.png');

if plot_images
    figure, imshow(imadjust(filter_response)), title('filter response');
end

if set_thresholds
    input_skeletonization = extract_vessels(filter_response, level_filter_low, level_filter_high);
else
    input_skeletonization = extract_vessels(filter_response);
end

if plot_images
    figure, imshow(input_skeletonization), title('vessels extracted');
end

% imwrite(input_skeletonization, 'input-skeletonization.png');

switch skeleton_method
    
    case 'voronoi'
        voronoi_skel = voronoiSkel(input_skeletonization);
        
        if plot_images
            ov = overlay_binary(img,imdilate(voronoi_skel,ones(5,5)),false);
            figure, imshow(ov,[]);
        end
        skel = bwmorph(voronoi_skel, 'thin', Inf);
        
    case 'thinning'
        
        skel = bwmorph(input_skeletonization, 'thin', Inf);
        
    case 'telea' % http://www.cs.rug.nl/~alext/PAPERS/VisSym02/dskel.pdf
        
        skel = skeleton(input_skeletonization);
        
    otherwise
        error('Wrong skeletonization method specified.');
end

% imwrite(skel, 'skeleton-thinning.png');

if plot_images
    ov = overlay_binary(img,imdilate(skel,ones(5,5)),false);
    figure, imshow(ov,[]), title('skeleton')
end

%% comment from here
% branches = 50;
% spurred_skel = skel;
% 
% for i_branch = 1:branches
%     
%     spurred_skel = bwmorph(spurred_skel, 'spur', 1);
%     skel = skel + spurred_skel;
%     
% end
% 
% skel = skel/max(skel(:));
% 
% if plot_images
%     figure, imshow(skel);
% end

% [~ ,exy,jxy] = anaskel(spurred_skel);
% 
% % Removing the small branches
% skel = bwmorph(skel, 'spur', branches);
% 
% if plot_images
%     ov = overlay_binary(img,imdilate(skel,ones(5,5)),false);
%     figure, imshow(ov,[]), title('spurred image')
% end
% 
% if plot_images
%     figure, imshow(skel > 0);
%     hold on
%     plot(exy(1,:),exy(2,:),'g.', 'MarkerSize', 20)
%     plot(jxy(1,:),jxy(2,:),'r.', 'MarkerSize', 20)
% end
% 
% n_deadend = size(exy, 2);
% neighbourhood = -1:1;
% 
% [n_lines, n_col, ~] = size(img);
% final_skeleton = skel == branches + 1;
% 
% 
% for i_deadend = 1:n_deadend
%     
%     current_i = exy(1, i_deadend);
%     current_j = exy(2, i_deadend);
%     
%     i_branch = branches;
%     
%     inside_image = (current_i > 1) && (current_i < n_col) && (current_j > 1) && (current_j < n_lines);
%     if ~inside_image
%         final_skeleton(current_i, current_j) = 0;
%     else
%         [j_add, i_add] = find(skel(current_j + neighbourhood, current_i + neighbourhood) == i_branch, 1, 'first');
%         end_of_branch = numel(j_add) == 0;
% 
%         while i_branch > 0 && inside_image && ~end_of_branch
%                 current_i = current_i + i_add - 2;
%                 current_j = current_j + j_add - 2;
%                 final_skeleton(current_j, current_i) = 1;
%                 exy(1,i_deadend) = current_i;
%                 exy(2,i_deadend) = current_j;
% 
%                 % Redefine the new booleans for next iteration
%                 inside_image = (current_i > 1) && (current_i < n_col) && (current_j > 1) && (current_j < n_lines);
%                 if inside_image
%                     [j_add, i_add] = find(skel(current_j + neighbourhood, current_i + neighbourhood) == i_branch, 1, 'first');
%                 end
%                 end_of_branch = numel(j_add) == 0;
% 
%         end
%     end
% end

% for i_deadend = 1:n_deadend
%
%     current_i = exy(1, i_deadend);
%     current_j = exy(2, i_deadend);
%
%     i_branch = branches;
%     for i_branch = branches:-1:1
%
%         if (current_i > 1) && (current_i < n_col) && (current_j > 1) && (current_j < n_lines)
%
%             [j_add, i_add] = find(skeleton(current_j + neighbourhood, current_i + neighbourhood) == i_branch, 1, 'first');
%             current_i = current_i + i_add - 2;
%             current_j = current_j + j_add - 2;
%             final_skeleton(current_j, current_i) = 1;
%             exy(1,i_deadend) = current_i;
%             exy(2,i_deadend) = current_j;
%         end
%     end
% end

% [~, exy, jxy] = anaskel(final_skeleton);
% 
% if plot_images
%     ov = overlay_binary(img,imdilate(final_skeleton,ones(5,5)),false);
%     figure, imshow(ov,[]), title('skeleton')
%     hold on
%     plot(exy(1,:),exy(2,:),'g.', 'MarkerSize', 20)
%     plot(jxy(1,:),jxy(2,:),'r.', 'MarkerSize', 20)
% end

% if plot_images
%     cutoff_value = 100;
%     node_list = [exy, jxy]';
%     pairwise_distances = pdist(node_list);
%     tree = linkage(node_list, 'average');
%     leafOrder = optimalleaforder(tree, pairwise_distances);
%     cluster(tree, 'cutoff', cutoff_value, 'criterion', 'distance');
%     
%     figure();
%     dendrogram(tree,'Reorder',leafOrder);
% end
end

