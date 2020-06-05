function node_directions = calculateNodeDirections(circle_x, circle_y, distances_ij, thresh)
    
    show_visualizations = false;
    if show_visualizations
        figure()
        voronoi(circle_x, circle_y);
    end
    
    if numel(circle_x) > 2
        dt = delaunay(circle_x, circle_y);
        % make the connections to single line segments such that I
        % can calculate the distances

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
    
    ids(distances > (thresh*1.75)^2, :) = []; % TODO: I am not happy with the factor.
    
    if show_visualizations
        hold on
        plot(circle_x(ids)', circle_y(ids)', 'r')
    end
    
    % now determine the 5 hop neighbors of each node
    % save id AND required number of hops! % TODO: optimaziation: hop
    % number not needed!
    N_hops = 5;
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
    
    if show_visualizations
        % neighbor visualizations
        for i = 1:numel(circle_x)
            f = figure();
            ax = axes(f);
            hold(ax, 'on');
            voronoi(ax, circle_x, circle_y);
            plot(ax, circle_x(ids)', circle_y(ids)', 'r')
            colors = {'b*', 'r*', 'y*', 'w*', 'g*'};
            for j = 1:N_hops
                scatter(ax, circle_x(neighbors_per_object{i, j}), circle_y(neighbors_per_object{i, j}), colors{j});
            end
            scatter(ax, circle_x(i), circle_y(i), 'k*')
        end
    end
    
    

    % angle determination of node i
    Ndim = 2;
    node_directions = zeros(Ndim, numel(circle_x));
    for i = 1:numel(circle_x)
        neighbors = vertcat(neighbors_per_object{i, :});
        directions = [circle_x(neighbors); circle_y(neighbors)] - [circle_x(i); circle_y(i)];
        directions = directions ./ vecnorm(directions, 2, 1);
        
        % turn the directions into positive x direction
        cond = directions(1, :) < 0;
        directions(:, cond) = -directions(:, cond);
        
        
        angles = zeros(numel(neighbors));
        for j = 1:length(angles)
            angles(j, :) = calc_angle_vec_new(directions(:, j), directions);
        end
        
        %voting
        votes = cellfun(@(x) histcounts(x, N_hops), num2cell(angles, 1), 'un', 0);
        votes = vertcat(votes{:});
        [~, idcs] = maxk(votes(:, 1), min(N_hops, size(votes, 1)));
        
        direction = mean(directions(:, idcs), 2);
        node_directions(:, i) = direction ./ norm(direction);
    end
    
    if show_visualizations
    % node direction visualization
        % neighbor visualizations        

        f = figure();
        ax = axes(f);
        hold(ax, 'on');
        scatter(ax, circle_x, circle_y)
        factor = 10;
        plot(ax, ...
            [circle_x; circle_x + factor*node_directions(1, :)], ...
            [circle_y; circle_y + factor*node_directions(2, :)], 'r')

    end

end