function objects = splitBinarayImage(im_binary, params)

    params_split_component = params.params_split_component;

    objects = bwconncomp(im_binary);

    updated_PixelIdxList = {};
    for i = 1:objects.NumObjects
        new_PixelIdxList = splitComponent(objects.PixelIdxList{i}, objects.ImageSize, params_split_component);
        updated_PixelIdxList(end+1:end+numel(new_PixelIdxList)) = new_PixelIdxList;
    end

    objects.NumObjects = numel(updated_PixelIdxList);
    objects.PixelIdxList = updated_PixelIdxList;

end