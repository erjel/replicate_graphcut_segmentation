function ax = visImage(im)
    f = figure();
    ax = axes(f);
    
    hold(ax, 'on');
    
    imagesc(ax, im);
    
    ax.YDir = 'normal';
    ax.DataAspectRatio = [1 1 1];
    ax.YLim = [0, size(im, 1)];
    ax.XLim = [0, size(im, 1)];
end

