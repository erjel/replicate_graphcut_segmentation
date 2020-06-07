function bool = is_terminal(ids, distances_ij, directions_ij, params)

    typical_cell_length = params.typical_cell_length;
    typical_cell_curvature = params.typical_cell_curvature;

    dist = distances_ij(ids, :);
    dist = dist(:, ids);
    
    dir = directions_ij(ids, :);
    dir = dir(:, ids);
    
    bool = max(dist) < typical_cell_length & max(dir) < typical_cell_curvature;

end