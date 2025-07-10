function cmap = geodesic(cmap, LineCol, Resolution, LineWidth)
    LineCol = (LineCol(:))';

    spacing = ceil(length(cmap) / Resolution);
    s2 = ceil(spacing/2);
    idxs = s2:spacing:(length(cmap)-s2);
    cmap(1:s2-1, :) = repmat(mean(cmap(1:s2-1, :)), s2 - 1, 1);
    for i = 1:length(idxs)-2
        j1 = idxs(i);
        j2 = idxs(i + 1) - 1;
        cmap(j1:j2, :) = repmat(mean(cmap(j1:j2, :)), spacing, 1);
    end
    cmap(idxs(end):end, :) = repmat(mean(cmap(idxs(end):end, :)), length(cmap)-idxs(end)+1, 1);
    if mod(LineWidth, 2) == 0
        l1 = -LineWidth/2 + 1;
        l2 = LineWidth/2;
    else
        l1 = -floor(LineWidth/2);
        l2 = floor(LineWidth/2);
    end
    for i = 1:length(idxs)
        j1 = idxs(i) + l1;
        j2 = idxs(i) + l2;
        cmap(j1:j2, :) = repmat(LineCol, LineWidth, 1);
    end
end

