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
    
    if show_visualizations
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
    
    % first create adjecency matrix
    dist_thresh = 50;
    sig_dist = 10;
    sig_theta = 0.1;

    W_dist = exp(-distances_ij.^2/(sig_dist^2));
    W_dist(distances_ij > dist_thresh) = 0;

    W_dir = exp(-(cos(directions_ij)-1) .^2 ./ sig_theta^2);

    W = W_dist .* W_dir;
    
    [id_start, id_end] = meshgrid(1:length(W), 1:length(W));
    id_start = id_start(tril(true(size(id_start)), -1));
    id_end = id_end(tril(true(size(id_end)), -1));
    
    edge_weights = arrayfun(@(x, y) W(x, y), id_start, id_end);
    
    factor_color = 1000;
    
    if show_visualizations
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
    
    

    W_subgraphs = {W};
    W_subgraph_ids = {1:numel(circle_x)};
    W_terminated = zeros(1, numel(W_subgraphs));

    safety_counter = 0;
    while ~all(W_terminated) || safety_counter > numel(circle_x)
        % Now split the as long as the stop criteria are met

        i = find(~W_terminated, 1);  % TODO: optimization: do not really need find if is_terminal is calculated at the end...
        ids = W_subgraph_ids{i};

        if show_visualizations
            f = figure(),
            ax = axes(f);
            hold(ax, 'on');
            imagesc(ax, im_binary);
            scatter(ax,  circle_y(ids), circle_x(ids), 'r')
        end

        if is_terminal(ids, distances_ij, directions_ij)
            W_terminated(i) = true;
        else
            w = W_subgraphs{i};

            nCluster = 2;
            clusterClasses = logical(ncutW(w, nCluster));

            w_first = w(:, clusterClasses(:, 1));
            w_first = w_first(clusterClasses(:, 1), :);

            w_second = w(:, clusterClasses(:, 2));
            w_second = w_second(clusterClasses(:, 2), :);

            ids_first = ids(clusterClasses(:, 1));
            ids_second = ids(clusterClasses(:, 2));
            
            if show_visualizations
                scatter(ax, circle_y(ids_first), circle_x(ids_first), 'w', 'filled');
                scatter(ax, circle_y(ids_second), circle_x(ids_second), 'g', 'filled');
            end
            W_subgraphs{i} = w_first;
            W_subgraphs{end+1} = w_second;

            W_subgraph_ids{i} = ids_first;
            W_subgraph_ids{end+1} = ids_second;
        end

        safety_counter = safety_counter + 1;
    end
    
    % Naive approach: for each pixelId calculate distance to all circle centers
    % N_px x N_c
    
    [x_px, y_px] = ind2sub(ImageSize, PixelIdxList);
    
    px_dist = (x_px - circle_x).^2 + (y_px - circle_y).^2;
    
    [~, center_id] = min(px_dist, [], 2);
    
    new_PixelIdxList = cell(1, numel(W_subgraph_ids));
    
    circle_center_ids = 1:numel(circle_x);
    
    for i = 1:numel(W_subgraph_ids)
        
        center_is_in_subgraph = ismember(circle_center_ids, W_subgraph_ids{i});
        pixel_is_in_subgraph = ismember(center_id, find(center_is_in_subgraph));

        new_PixelIdxList{i} = PixelIdxList(pixel_is_in_subgraph);

    end

end