function new_PixelIdxList = splitComponent(PixelIdxList, ImageSize, params)

    radius_thresh = params.radius_thresh;
    show_vis = params.show_vis;
    
    params_inscribed_circles = params.params_inscribed_circles;
    params_node_directions = params.params_node_directions;
    params_construct_graph = params.params_construct_graph;
    params_divide_graph = params.params_divide_graph;
    

    im_binary = false(ImageSize);
    im_binary(PixelIdxList) = true;
    
    dist_trans = bwdist(~im_binary);
   
    if show_vis
        visImage(dist_trans);
    end

    [circle_x, circle_y, circle_radii] = inscribedCircles(im_binary, dist_trans, params_inscribed_circles);
    
    [circle_x_new, circle_y_new, circle_radii_new] =  ...
        restrictCircleRadii(circle_x, circle_y, circle_radii, radius_thresh, ...
        dist_trans);

    if show_vis
        visCircleSplitting(im_binary, ...
             circle_x, circle_y, circle_radii, ...
             circle_x_new, circle_y_new, circle_radii_new, radius_thresh)
    end
    
    circle_x = circle_x_new;
    circle_y = circle_y_new;
    clear('circle_radii', 'circle_radii_new');

    
    %% Generate graph for lCut method
    distances_ij = squareform(pdist([circle_x', circle_y']));
    node_directions = calculateNodeDirections(circle_x, circle_y, distances_ij, radius_thresh, params_node_directions);

    directions_ij = zeros(size(node_directions, 2));
    for j = 1:length(directions_ij)
        directions_ij(j, :) = calc_angle_vec_new(node_directions(:, j), node_directions);
    end
    
    W = constructGraph(distances_ij, directions_ij, params_construct_graph);
    
    if show_vis
        visEdges(im_binary, circle_x, circle_y, distances_ij);
        visEdges(im_binary, circle_x, circle_y, directions_ij);
        visEdges(im_binary, circle_x, circle_y, W);
    end
    
    W_subgraph_ids = divideGraph(W, circle_x, circle_y, distances_ij, directions_ij, params_divide_graph);

    new_PixelIdxList = updatePixelIdxList(PixelIdxList, W_subgraph_ids, ...
        circle_x, circle_y, ImageSize);
end