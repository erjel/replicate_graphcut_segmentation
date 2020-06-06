function ax = visEdges(im, edge_x, edge_y, edge_ij)

        x_occupied = any(im, 1);
        x_max = find(x_occupied, 1, 'last');
        x_min = find(x_occupied, 1);
        
        y_occupied = any(im, 2);
        y_max = find(y_occupied, 1, 'last');
        y_min = find(y_occupied, 1);
        
        [id_start, id_end] = meshgrid(1:length(edge_ij), 1:length(edge_ij));
        id_start = id_start(tril(true(size(id_start)), -1));
        id_end = id_end(tril(true(size(id_end)), -1));
        
        edge_values = arrayfun(@(x, y) edge_ij(x, y), id_start, id_end);
        
        if range(edge_values) < 20
            edge_values = 100 / max(edge_values(:)) * edge_values;
        end

        cm = parula(ceil(max(edge_values(:))));
        
        ax = visImage(im(y_min:y_max,x_min:x_max));
        
        for i = 1:numel(id_start)
            l = plot(ax, ...
                [edge_y(id_start(i)); edge_y(id_end(i))] - x_min, ...
                [edge_x(id_start(i)); edge_x(id_end(i))] - y_min, ...
                'LineWidth', 2);
            
            if edge_angles(i) ~= 0
                l.Color = cm(ceil(edge_values(i)), :);
            end
            
        end
        cb = colorbar(ax);       
end