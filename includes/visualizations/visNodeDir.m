function visNodeDir(node_x, node_y, node_directions)
    factor = 10;

    f = figure();
    ax = axes(f);
    hold(ax, 'on');
    scatter(ax, node_x, node_y)
    
    plot(ax, ...
        [node_x; node_x + factor*node_directions(1, :)], ...
        [node_y; node_y + factor*node_directions(2, :)], 'r')
end