% create binary image

im = imread3D('D:\Projects\Replicate_LCut_Declumping\data\Pos11_frame000030_Nz19.tif');


im = im(250:500, 350:600, :);

% find brightest plane in stack
[~, i] = max(sum(sum(im, 1) ,2));
im = im(:, :, 6);


figure();
imagesc(im);

im_binary = medfilt2(imbinarize(im), [3, 3]);

figure();
imagesc(im_binary);

objects = bwconncomp(im_binary);
props = regionprops(objects);
[~, id] = max([props.Area]);


%TODO: program-flow: decisision which objects have to be splitted

splitObjects(objects.PixelIdxList{id}, objects.ImageSize);




