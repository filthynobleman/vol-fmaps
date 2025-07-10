function plot_streamlines(M, f, gradient)
%PLOT_GRADIENT Summary of this function goes here
%   Detailed explanation goes here

    trisurf(M.TRIV, M.VERT(:, 1), M.VERT(:, 2), M.VERT(:, 3), f);
    axis equal;
    axis off;
    shading interp;
    light;
    lighting phong;
%     camlight head;
    hold on;
    % If gradient is on triangles, application point is the centroid of
    % each triangle
    if size(gradient, 1) == M.m
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
    U = gradient(:, 1);
    V = gradient(:, 2);
    W = gradient(:, 3);
    
    
    x = linspace(min(X), max(X), 100);
    y = linspace(min(Y), max(Y), 100);
    z = linspace(min(Z), max(Z), 100);
    [XX, YY, ZZ] = meshgrid(x, y, z);
    [~, IdxX] = min((XX - X).^2, 2);
    [~, IdxY] = min((YY - Y).^2, 2);
    [~, IdxZ] = min((ZZ - Z).^2, 2);
    Idx = intersect(IdxX, IdxY);
    Idx = intersect(Idx, IdxZ);
    UU = zeros(size(XX));
    VV = zeros(size(YY));
    WW = zeros(size(ZZ));
    UU(Idx) = U;
    VV(Idx) = V;
    WW(Idx) = W;
    
    start = find(vecnorm(gradient, 2, 2) < 1e-3);
    
    
    % Plot the arrows
%     quiver3(X, Y, Z, U, V, W, 'Color', 'g')
    streamline(XX, YY, ZZ, UU, VV, WW, X(start), Y(start), Z(start));%, 'Color', 'g')
    hold off;

end

