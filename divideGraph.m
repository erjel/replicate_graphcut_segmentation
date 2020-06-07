function W_subgraph_ids = divideGraph(W, circle_x, circle_y, distances_ij, directions_ij, params)

    show_vis = params.show_vis;
    params_is_terminal = params.params_is_terminal;
    
    W_subgraphs = {W};
    W_subgraph_ids = {1:numel(circle_x)};
    W_terminated = zeros(1, numel(W_subgraphs));

    safety_counter = 0;
    while ~all(W_terminated) || safety_counter > numel(circle_x)
        % Now split the as long as the stop criteria are met

        i = find(~W_terminated, 1);  % TODO: optimization: do not really need find if is_terminal is calculated at the end...
        ids = W_subgraph_ids{i};

        if show_vis
            f = figure(),
            ax = axes(f);
            hold(ax, 'on');
            imagesc(ax, im_binary);
            scatter(ax,  circle_y(ids), circle_x(ids), 'r')
        end

        if is_terminal(ids, distances_ij, directions_ij, params_is_terminal)
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
            
            if show_vis
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
end