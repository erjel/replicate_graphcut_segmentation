function objects_new = splitObjects(PixelIdxList, ImageSize)

    im_binary = zeros(ImageSize);
    im_binary(PixelIdxList) = true;
    
    f = figure();
    ax  = axes(f);
    dist_trans = bwdist(~im_binary);
    imagesc(dist_trans)
    ax.YDir = 'normal';

    im_skel = bwmorph(im_binary,'skel',Inf);

    f = figure();
    ax = axes(f);
    imagesc(im_skel);
    ax.YDir = 'normal';

    % From skeleton and distance transform I now need to calculate the
    % inscribed circles

    [columnsInImage rowsInImage] = meshgrid(1:size(im_binary, 1), 1:size(im_binary, 2));

    px_perim = zeros(size(im_skel));
    im_skel_curr = im_skel;
    circle_x = [];
    circle_y = [];
    circle_radii = [];

    while any(im_skel_curr(:))

        skeleton_points = find(im_skel_curr); % todo: better setdiff?
        radii = dist_trans(skeleton_points);  % todo: better only delete indices?
        [radius, idx] = max(radii);

        [x, y] = ind2sub(size(im_skel), skeleton_points(idx));

        circle_x(end+1) = x;
        circle_y(end+1) = y;
        circle_radii(end+1)= radius;

        circlePixels = (rowsInImage - x).^2 ...
            + (columnsInImage - y).^2 <= radius.^2;

        px_perim = px_perim + bwperim(circlePixels);

        im_skel_curr = im_skel_curr & ~circlePixels;
    end

    %% Viszualize results

    f = figure();
    ax = axes(f);
    hold(ax, 'on');
    imagesc(ax, im_binary);

    ax.YDir = 'normal';
    ax.DataAspectRatio = [1 1 1];
    ax.YLim = [0, size(im_binary, 1)];
    ax.XLim = [0, size(im_binary, 1)];

    thresh = 6;

    draw_circles(ax, ...
        circle_x(circle_radii < thresh) ,...
        circle_y(circle_radii < thresh), ...
        circle_radii(circle_radii < thresh), 'b');

    draw_circles(ax, ...
        circle_x(circle_radii > thresh) ,...
        circle_y(circle_radii > thresh), ...
        circle_radii(circle_radii > thresh), 'w');


    %% modify circles which are too large

    last_idx_too_large = find(circle_radii > thresh, 1, 'last');

    for i = 1:last_idx_too_large
        r = circle_radii(i);
        x = circle_x(i);
        y = circle_y(i);
        new_num = ceil(r / thresh);

        desired_radius = r / new_num;

        dist = (rowsInImage - x).^2 ...
            + (columnsInImage - y).^2;

        circlePixels = dist <= r.^2;

        candidate_centers = dist_trans .* circlePixels;

        mask = (candidate_centers < desired_radius) & circlePixels;


        x_new = zeros(1, new_num);
        y_new = zeros(1, new_num);
        r_new = zeros(1, new_num);

        candidate_centers_dist = dist(mask);
        [~, idx] = min(candidate_centers_dist);

        row_idxs = rowsInImage(mask);
        col_idxs = columnsInImage(mask);
        radii_idxs = dist_trans(mask);

        x_new(1) = row_idxs(idx);
        y_new(1) = col_idxs(idx);
        r_new(1) = radii_idxs(idx);

        % Assumptions:
        % - other circle are must be on the oposite site of center point
        % - there are only 2 points
        assert(new_num == 2)

        tmp = [x, y] - [x_new(1) - x, y_new(1) - y];
        x_new(2) = tmp(1);
        y_new(2) = tmp(2);
        r_new(2) = dist_trans(x_new(2), y_new(2));

        draw_circles(ax, x_new, y_new, r_new, 'g');

        circle_x(end+1:end+2) = x_new;
        circle_y(end+1:end+2) = y_new;
        circle_radii(end+1:end+2) = r_new;
    end

    circle_x(1:last_idx_too_large) = [];
    circle_y(1:last_idx_too_large) = [];
    circle_radii(1:last_idx_too_large) = [];

    %% Generate graph for lCut method




    distances_ij = squareform(pdist([circle_x', circle_y']));
    node_directions = determineTheta(circle_x, circle_y, distances_ij, thresh);

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
        plot(ax, ...
        [circle_y(id_start(i)); circle_y(id_end(i))] - x_min, ...
        [circle_x(id_start(i)); circle_x(id_end(i))] - y_min, ...
        'Color', cm_dir(ceil(edge_angles(i)), :), ...
        'LineWidth', 2)
    end
    
    cb = colorbar(ax);
    
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
    
    
    

    W_subgraphs = {W};
    W_subgraph_ids = {1:numel(circle_x)};
    W_terminated = zeros(1, numel(W_subgraphs));

    safety_counter = 0;
    while ~all(W_terminated) || safety_counter > numel(circle_x)
        % Now split the as long as the stop criteria are met

        i = find(~W_terminated, 1);  % TODO: optimization: do not really need find if is_terminal is calculated at the end...
        ids = W_subgraph_ids{i};

        f = figure(),
        ax = axes(f);
        hold(ax, 'on');
        imagesc(ax, im_binary);
        scatter(ax,  circle_y(ids), circle_x(ids), 'r')

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

            scatter(ax, circle_y(ids_first), circle_x(ids_first), 'w', 'filled');
            scatter(ax, circle_y(ids_second), circle_x(ids_second), 'g', 'filled');

            W_subgraphs{i} = w_first;
            W_subgraphs{end+1} = w_second;

            W_subgraph_ids{i} = ids_first;
            W_subgraph_ids{end+1} = ids_second;
        end

        safety_counter = safety_counter + 1;
    end
    
    % TODO: workflow: Split the pixelIdxList based on the pixels (maybe just distance to circles?)
    
    
    
    
    


end