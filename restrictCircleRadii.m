function [circle_x, circle_y, circle_radii] = restrictCircleRadii( ...
    circle_x, circle_y, circle_radii, radius_thresh, dist_trans)

    ImageSize = size(dist_trans);
    
    [columnsInImage, rowsInImage] = meshgrid( ...
        1:ImageSize(1), 1:ImageSize(2));

    last_idx_too_large = find(circle_radii > radius_thresh, 1, 'last');

    for i = 1:last_idx_too_large
        r = circle_radii(i);
        x = circle_x(i);
        y = circle_y(i);
        new_num = ceil(r / radius_thresh);

        desired_radius = r / new_num;

        dist = (rowsInImage - x).^2 ...
            + (columnsInImage - y).^2;

        circlePixels = dist <= r.^2;

        candidate_centers = dist_trans .* circlePixels;

        mask = (candidate_centers < desired_radius) & circlePixels;


        x_new = zeros(1, new_num);
        y_new = zeros(1, new_num);
        r_new = zeros(1, new_num);

        candidate_centers_dist = dist(mask);
        [~, idx] = min(candidate_centers_dist);

        row_idxs = rowsInImage(mask);
        col_idxs = columnsInImage(mask);
        radii_idxs = dist_trans(mask);

        x_new(1) = row_idxs(idx);
        y_new(1) = col_idxs(idx);
        r_new(1) = radii_idxs(idx);

        % Assumptions:
        % - other circle are must be on the oposite site of center point
        % - there are only 2 points
        assert(new_num == 2)

        tmp = [x, y] - [x_new(1) - x, y_new(1) - y];
        x_new(2) = tmp(1);
        y_new(2) = tmp(2);
        r_new(2) = dist_trans(x_new(2), y_new(2));
        
        circle_x(end+1:end+2) = x_new;
        circle_y(end+1:end+2) = y_new;
        circle_radii(end+1:end+2) = r_new;
    end

    circle_x(1:last_idx_too_large) = [];
    circle_y(1:last_idx_too_large) = [];
    circle_radii(1:last_idx_too_large) = [];