function new_PixelIdxList = updatePixelIdxList(PixelIdxList, W_subgraph_ids, ...
        circle_x, circle_y, ImageSize)   


[x_px, y_px] = ind2sub(ImageSize, PixelIdxList);
    
    px_dist = (x_px - circle_x).^2 + (y_px - circle_y).^2;
    
    [~, center_id] = min(px_dist, [], 2);
    
    new_PixelIdxList = cell(1, numel(W_subgraph_ids));
    
    circle_center_ids = 1:numel(circle_x);
    
    for i = 1:numel(W_subgraph_ids)
        
        center_is_in_subgraph = ismember(circle_center_ids, W_subgraph_ids{i});
        pixel_is_in_subgraph = ismember(center_id, find(center_is_in_subgraph));

        new_PixelIdxList{i} = PixelIdxList(pixel_is_in_subgraph);

    end
    
end