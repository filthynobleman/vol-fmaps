function plot_normals(M)
%PLOT_NORMALS Summary of this function goes here
%   Detailed explanation goes here

    N = mesh.proc.normal(M);
    V = zeros(M.m, 3);
    for i = 1:3
        V = V + M.VERT(M.TRIV(:, i), :);
    end
    V = V ./ 3;
    
    utils.plot_scalar_map(M);
    shading faceted;
    hold on;
    quiver3(V(:, 1), V(:, 2), V(:, 3), ...
            N(:, 1), N(:, 2), N(:, 3), ...
            'Color', 'g');
    

end

