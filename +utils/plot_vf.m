function plot_vf(M, f, vf)
%PLOT_GRADIENT Summary of this function goes here
%   Detailed explanation goes here

    if nargin < 3
        utils.plot_scalar_map(M);
        vf = f;
    else
        utils.plot_scalar_map(M, f, utils.cmaps.bwr);
    end
    hold on;
    % If gradient is on triangles, application point is the centroid of
    % each triangle
    if size(vf, 1) == M.m
        % Compute the centers of the triangles
        X1 = M.VERT(M.TRIV(:, 1), :);
        X2 = M.VERT(M.TRIV(:, 2), :);
        X3 = M.VERT(M.TRIV(:, 3), :);
        centers = (X1 + X2 + X3) / 3;
        % Compute the application points
        X = centers(:, 1);
        Y = centers(:, 2);
        Z = centers(:, 3);
    % Otherwise, application points are the vertices
    else
        X = M.VERT(:, 1);
        Y = M.VERT(:, 2);
        Z = M.VERT(:, 3);
    end
    U = vf(:, 1);
    V = vf(:, 2);
    W = vf(:, 3);
    % Plot the arrows
    h = quiver3(X, Y, Z, U, V, W, 10);
    utils.SetQuiverColor(h, utils.cmaps.blend([0 0 0; 0 1 0], 256));
    hold off;

end

