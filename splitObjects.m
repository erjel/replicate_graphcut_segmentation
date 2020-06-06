function new_PixelIdxList = splitObjects(PixelIdxList, ImageSize)

    %%%%% parameters %%%%%
    show_visualizations = false;
    radius_thresh = 6;
    
    
    %%%%% main %%%%%
    im_binary = false(ImageSize);
    im_binary(PixelIdxList) = true;
    
    dist_trans = bwdist(~im_binary);
   
    if show_visualizations
        
        f = figure();
        ax  = axes(f);
        imagesc(dist_trans)
        ax.YDir = 'normal';
    end

    [circle_x, circle_y, circle_radii] = inscribedCircles(im_binary, dist_trans);
    
    [circle_x_new, circle_y_new, circle_radii_new] =  ...
        restrictCircleRadii(circle_x, circle_y, circle_radii, radius_thresh, ...
        dist_trans);

    %% Viszualize results
    if show_visualizations
        f = figure();
        ax = axes(f);
        hold(ax, 'on');
        imagesc(ax, im_binary);

        ax.YDir = 'normal';
        ax.DataAspectRatio = [1 1 1];
        ax.YLim = [0, size(im_binary, 1)];
        ax.XLim = [0, size(im_binary, 1)];
        
        
        draw_circles(ax, ...
            circle_x_new,...
            circle_y_new, ...
            circle_radii_new, 'g');
    
        draw_circles(ax, ...
            circle_x(circle_radii < radius_thresh) ,...
            circle_y(circle_radii < radius_thresh), ...
            circle_radii(circle_radii < radius_thresh), 'b');

        draw_circles(ax, ...
            circle_x(circle_radii > radius_thresh) ,...
            circle_y(circle_radii > radius_thresh), ...
            circle_radii(circle_radii > radius_thresh), 'w');
    
    end
    
    circle_x = circle_x_new;
    circle_y = circle_y_new;
    circle_radii = circle_radii_new;

    
    %% Generate graph for lCut method
    distances_ij = squareform(pdist([circle_x', circle_y']));
    node_directions = calculateNodeDirections(circle_x, circle_y, distances_ij, radius_thresh);

    directions_ij = zeros(size(node_directions, 2));
    for j = 1:length(directions_ij)
        directions_ij(j, :) = calc_angle_vec_new(node_directions(:, j), node_directions);
    end
    
    if show_visualizations
        % visualization of edges
        x_occupied = any(im_binary, 1);
        x_max = find(x_occupied, 1, 'last');
        x_min = find(x_occupied, 1);
        
        y_occupied = any(im_binary, 2);
        y_max = find(y_occupied, 1, 'last');
        y_min = find(y_occupied, 1);
        
        [id_start, id_end] = meshgrid(1:length(distances_ij), 1:length(distances_ij));
        id_start = id_start(tril(true(size(id_start)), -1));
        id_end = id_end(tril(true(size(id_end)), -1));
        
        edge_distances = arrayfun(@(x, y) distances_ij(x, y), id_start, id_end);
        edge_angles = arrayfun(@(x, y) directions_ij(x, y), id_start, id_end);
        edge_angles = edge_angles * 100;
        
        cm_dist = parula(ceil(max(edge_distances(:))));
        cm_dir = parula(ceil(max(edge_angles(:))));
        
        f = figure();
        ax = axes(f);
        hold(ax, 'on');
        
        imagesc(ax, im_binary(y_min:y_max,x_min:x_max))
        ax.YDir = 'normal';
        
        for i = 1:numel(id_start)
            plot(ax, ...
                [circle_y(id_start(i)); circle_y(id_end(i))] - x_min, ...
                [circle_x(id_start(i)); circle_x(id_end(i))] - y_min, ...
                'Color', cm_dist(ceil(edge_distances(i)), :), ...
                'LineWidth', 2)
        end
        cb = colorbar(ax);
        
        f = figure();
        ax = axes(f);
        hold(ax, 'on');
        
        imagesc(ax, im_binary(y_min:y_max,x_min:x_max))
        ax.YDir = 'normal';
        
        for i = 1:numel(id_start)
            l = plot(ax, ...
                [circle_y(id_start(i)); circle_y(id_end(i))] - x_min, ...
                [circle_x(id_start(i)); circle_x(id_end(i))] - y_min, ...
                'LineWidth', 2);
            
            if edge_angles(i) ~= 0
                l.Color = cm_dir(ceil(edge_angles(i)), :);
            end
            
        end
        
        cb = colorbar(ax);
    end
    
    W = constructGraph(distances_ij, directions_ij);
    
    if show_visualizations
        [id_start, id_end] = meshgrid(1:length(W), 1:length(W));
        id_start = id_start(tril(true(size(id_start)), -1));
        id_end = id_end(tril(true(size(id_end)), -1));
        
        edge_weights = arrayfun(@(x, y) W(x, y), id_start, id_end);
        
        factor_color = 1000;
        
        
        cm = parula(ceil(max(edge_weights) * factor_color));
        
        f = figure();
        ax = axes(f);
        hold(ax, 'on');
        
        imagesc(ax, im_binary(y_min:y_max,x_min:x_max))
        ax.YDir = 'normal';
        
        for i = 1:numel(id_start)
            weight = edge_weights(i) * factor_color;
            if weight == 0
                continue
            end
            plot(ax, ...
                [circle_y(id_start(i)); circle_y(id_end(i))] - x_min, ...
                [circle_x(id_start(i)); circle_x(id_end(i))] - y_min, ...
                'Color', cm(ceil(weight), :), ...
                'LineWidth', 2)
        end
        cb = colorbar();
    end
    
    W_subgraph_ids = divideGraph(W, circle_x, circle_y, distances_ij, directions_ij);


    new_PixelIdxList = updatePixelIdxList(PixelIdxList, W_subgraph_ids, ...
        circle_x, circle_y, ImageSize);
end