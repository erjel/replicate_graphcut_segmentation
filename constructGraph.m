function W = constructGraph(distances_ij, directions_ij)
    %%%% parameters %%%%
    dist_thresh = 50;
    sig_dist = 10;
    sig_theta = 0.1;
    
    %%%% main %%%%

    W_dist = exp(-distances_ij.^2/(sig_dist^2));
    W_dist(distances_ij > dist_thresh) = 0;

    W_dir = exp(-(cos(directions_ij)-1) .^2 ./ sig_theta^2);

    W = W_dist .* W_dir;
    
end