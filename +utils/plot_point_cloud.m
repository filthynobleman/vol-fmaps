function plot_point_cloud(M, f, pts, cmap, zero_centered)

    if nargin < 5
        zero_centered = true;
    end

    if zero_centered
        L = max(abs(f));
        RGB = f + L;
        RGB = RGB ./ (2 * L);
    else
        RGB = f - min(f);
        RGB = RGB ./ max(RGB);
    end
    RGB = round(RGB .* (length(cmap) - 1)) + 1;
    RGB = cmap(RGB, :);
    scatter3(M.VERT(pts, 1), M.VERT(pts, 2), M.VERT(pts, 3), 64, RGB, 'filled');

end

