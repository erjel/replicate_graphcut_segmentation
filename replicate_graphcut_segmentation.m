%%%% parameters %%%%
filename = fullfile('data', 'Pos11_frame000030_Nz19.tif');
show_vis = false;
show_result = true;


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

objects = splitBinarayImage(im_binary);


if show_result
    f = figure();
    w = labelmatrix(objects);
    colors = [[0, 0, 0]; rand([max(w(:)), 3])];
    imagesc(reshape(colors(w+1, :), [objects.ImageSize, 3]));
end



