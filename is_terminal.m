function bool = is_terminal(ids, distances_ij, directions_ij)
    %TODO: These parameters have to be set globally
    typical_cell_length = 20;
    typical_cell_curvature = 0.3;
    
    dist = distances_ij(ids, :);
    dist = dist(:, ids);
    
    dir = directions_ij(ids, :);
    dir = dir(:, ids);
    
    bool = max(dist) < typical_cell_length & max(dir) < typical_cell_curvature;

end