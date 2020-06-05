function [circle_x, circle_y, circle_radii] = inscribedCircles(im_binary, dist_trans)

    %%%% parameters
    show_visualizations = false;
    
    %%%% main

    ImageSize = size(im_binary);
    im_skel = bwmorph(im_binary,'skel',Inf);
    
    [columnsInImage, rowsInImage] = meshgrid( ...
            1:ImageSize(1), 1:ImageSize(2));
    
    if show_visualizations
    
        f = figure();
        ax = axes(f);
        imagesc(im_skel);
        ax.YDir = 'normal'; 
    end

    circle_x = [];
    circle_y = [];
    circle_radii = [];

    while any(im_skel(:))
        skeleton_points = find(im_skel); % todo: better setdiff?
        radii = dist_trans(im_skel);  % todo: better only delete indices?
        [radius, idx] = max(radii);

        [x, y] = ind2sub(ImageSize, skeleton_points(idx));

        circle_x(end+1) = x;
        circle_y(end+1) = y;
        circle_radii(end+1)= radius;

        circlePixels = (rowsInImage - x).^2 ...
            + (columnsInImage - y).^2 <= radius.^2;

        im_skel = im_skel & ~circlePixels;
    end
end