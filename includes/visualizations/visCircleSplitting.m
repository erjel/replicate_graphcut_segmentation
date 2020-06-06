function visCircleSplitting(im_binary, ...
     circle_x, circle_y, circle_radii, ...
     circle_x_new, circle_y_new, circle_radii_new, radius_thresh)

    ax = visImage(im_binary);

    visCircles(ax, circle_x_new, circle_y_new, ...
        circle_radii_new, 'g');

    cond = circle_radii <= radius_thresh;

    visCircles(ax, circle_x(cond), circle_y(cond), ...
        circle_radii(cond), 'b');

    visCircles(ax, circle_x(~cond), circle_y(~cond), ...
        circle_radii(~cond), 'w');

end