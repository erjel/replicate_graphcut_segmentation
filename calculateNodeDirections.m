function node_directions = calculateNodeDirections(circle_x, circle_y, distances_ij, thresh, params)

    dist_thresh_factor = params.dist_thresh_factor;
    Ndim = params.Ndim;
    N_hops = params.N_hops;
    show_vis = params.show_vis;
    
    if numel(circle_x) > 2
        dt = delaunay(circle_x, circle_y);
        
        % triangular indices to edge indices 
        ids = repelem(dt,1, 2);
        ids = [ids(:, end), ids(:, 1:end-1)]';
        ids = reshape(ids,2, [])';
        
    elseif numel(circle_x) == 2
        ids = [[1, 2]; [2, 1]];
    else
        % TODO: Error handling: Either prevent further splitting upstream,
        % or add proper error handling.
        error('Can not calculate direction with single node!')
    end
    
    distances = distances_ij(sub2ind(size(distances_ij), ids(:, 1),ids(:, 2)));
    
    ids(distances > (thresh*dist_thresh_factor)^2, :) = []; % TODO: I am not happy with the factor.
    
    if show_vis
        visNeighbors(circle_x, circle_y, ids);
    end
    
    % now determine the 5 hop neighbors of each node
    % TODO: optimization: hop number only needed for visualization!
    neighbors_per_object = cell(numel(circle_x), N_hops);
    for i = 1:numel(circle_x)
        all_ids = i;
        old_ids = i;
        for j = 1:N_hops
            all_ids = union(all_ids, ids(ismember(ids(:, 1), all_ids), 2));
            neighbors_per_object{i, j} = setdiff(all_ids, old_ids);
            old_ids = all_ids;
        end
    end
    
    if show_vis             
        for i = 1:numel(circle_x)
            visHopNeighbors(i, circle_x, circle_y, ids, N_hops, neighbors_per_object)
        end
    end
    
    node_directions = zeros(Ndim, numel(circle_x));
    for i = 1:numel(circle_x)
        neighbors = vertcat(neighbors_per_object{i, :});
        directions = [circle_x(neighbors); circle_y(neighbors)] - [circle_x(i); circle_y(i)];
        directions = directions ./ vecnorm(directions, 2, 1);
        
        % only use direction in half of the quadrants
        cond = directions(1, :) < 0;
        directions(:, cond) = -directions(:, cond);
        
        
        angles = zeros(numel(neighbors));
        for j = 1:length(angles)
            angles(j, :) = calc_angle_vec_new(directions(:, j), directions);
        end
        
        % voting
        votes = cellfun(@(x) histcounts(x, N_hops), num2cell(angles, 1), 'un', 0);
        votes = vertcat(votes{:});
        [~, idcs] = maxk(votes(:, 1), min(N_hops, size(votes, 1)));
        
        direction = mean(directions(:, idcs), 2);
        node_directions(:, i) = direction ./ norm(direction);
    end
    
    if show_vis
        visNodeDir(circle_x, circle_y, node_directions)
    end

end