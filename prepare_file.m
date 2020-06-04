im = imread3D('T:\Sample Data Single Cell\Pos11_frame000030_Nz19.tif');

im = im(:, :, 2:end);

imwrite3D(im, 'data/Pos11_frame000030_Nz19.tif')

