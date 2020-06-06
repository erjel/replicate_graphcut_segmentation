function angles = calc_angle_vec_new(x, y)
    % from https://www.mathworks.com/matlabcentral/answers/16243-angle-between-two-vectors-in-3d
    % calc_angle_vec = @(x, y) 2 * atan(norm(x*norm(y) - norm(x)*y) / norm(x * norm(y) + norm(x) * y));

    angles =  2 * atan(vecnorm(x*vecnorm(y, 2, 1) - vecnorm(x, 2, 1)*y, 2, 1) ./ vecnorm(x * vecnorm(y, 2, 1) + vecnorm(x, 2, 1) * y, 2, 1));
    return
end
