%%%% parameters %%%%
filename = fullfile('data', 'Pos11_frame000030_Nz19.tif');
show_vis = false;
show_result = true;

params_split_component.show_vis = false;
params_split_component.radius_thresh = 6;

params_inscribed_circles.show_vis = false;

params_node_directions.dist_thresh_factor = 1.75;
params_node_directions.Ndim = 2;
params_node_directions.N_hops = 5;
params_node_directions.show_vis = false;

params_construct_graph.dist_thresh = 50;
params_construct_graph.sig_dist = 10;
params_construct_graph.sig_theta = 0.1;

params_divide_graph.show_vis = false;

params_is_terminal.typical_cell_length = 20;
params_is_terminal.typical_cell_curvature = 0.3;

%%%% build parameter stack
params_divide_graph.params_is_terminal = params_is_terminal;
params_split_component.params_divide_graph = params_divide_graph;
params_split_component.params_construct_graph = params_construct_graph;
params_split_component.params_node_directions = params_node_directions;
params_split_component.params_inscribed_circles = params_inscribed_circles;
params.params_split_component = params_split_component;


%%%% main %%%%
addpath(genpath('external'));
addpath(genpath('includes'));

im = imread3D(filename);

% TODO: Functionality: Extend to 3D
[~, idx_z] = max(sum(im, [1, 2]));
im = im(:, :, idx_z);

% TODO: Functionality: Add proper semantic segmentation
im_binary = medfilt2(imbinarize(im), [3, 3]);

if show_vis
    visImage(im);
    visImage(im_binary);
end

objects = splitBinarayImage(im_binary, params);


if show_result
    f = figure();
    w = labelmatrix(objects);
    colors = [[0, 0, 0]; rand([max(w(:)), 3])];
    imagesc(reshape(colors(w+1, :), [objects.ImageSize, 3]));
end



