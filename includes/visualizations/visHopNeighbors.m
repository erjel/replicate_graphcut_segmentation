function visHopNeighbors(i, circle_x, circle_y, ids, N_hops, neighbors_per_object)

    colors = {'b*', 'r*', 'y*', 'w*', 'g*'};
    
    assert(numel(colors) == N_hops);

    ax = visNeighbors(circle_x, circle_y, ids);

    for j = 1:N_hops
        scatter(ax, circle_x(neighbors_per_object{i, j}), circle_y(neighbors_per_object{i, j}), colors{j});
    end
    scatter(ax, circle_x(i), circle_y(i), 'k*')
    
end