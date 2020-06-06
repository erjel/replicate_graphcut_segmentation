%%%% parameters %%%%
filename = fullfile('data', 'Pos11_frame000030_Nz19.tif');
show_visualisations = false;
show_result = true;


%%%% imports %%%%
addpath(genpath('external'));


%%%% main %%%%

% Read 3D tif stack
im = imread3D(filename);

% TODO: Functionality: Extend to 3D
[~, idx_z] = max(sum(im, [1, 2]));
im = im(:, :, idx_z);

im_binary = medfilt2(imbinarize(im), [3, 3]);

if show_visualisations
    figure();
    imagesc(im);
    
    figure();
    imagesc(im_binary);
end

objects = bwconncomp(im_binary);

updated_PixelIdxList = {};
for i = 1:objects.NumObjects
    new_PixelIdxList = splitObjects(objects.PixelIdxList{i}, objects.ImageSize);
    updated_PixelIdxList(end+1:end+numel(new_PixelIdxList)) = new_PixelIdxList;
end

objects.NumObjects = numel(updated_PixelIdxList);
objects.PixelIdxList = updated_PixelIdxList;

if show_result
    f = figure();
    w = labelmatrix(objects);
    colors = [[0, 0, 0]; rand([max(w(:)), 3])];
    imagesc(reshape(colors(w+1, :), [objects.ImageSize, 3]));
end



