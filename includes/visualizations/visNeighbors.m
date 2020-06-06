function ax = visNeighbors(node_x, node_y, edge_ids)     

    f = figure();
    ax = axes(f);
    hold(ax, 'on');

    voronoi(ax, node_x, node_y);
    plot(ax, node_x(edge_ids)', node_y(edge_ids)', 'r')
end