function plot_rgb_map(M, RGB, shading_opt)

    if nargin < 3
        shading_opt = 'interp';
    end

    trisurf(M.TRIV, M.VERT(:, 1), M.VERT(:, 2), M.VERT(:, 3), 'FaceColor','interp','FaceVertexCData',RGB,'EdgeColor','none');
    shading(shading_opt);
    axis off;
    axis equal;

end

