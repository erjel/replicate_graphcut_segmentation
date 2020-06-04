function draw_circles(ax, x, y, r, color)
    th = 0:pi/50:2*pi;
        
    for i = 1:numel(x)
        xunit = r(i) * cos(th) + y(i);
        yunit = r(i) * sin(th) + x(i);
        plot(ax, xunit, yunit, color,  'LineWidth', 2);
    end
end