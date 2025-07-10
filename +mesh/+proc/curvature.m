function [Curvature, OnVerts, MinCurv, MaxCurv] = curvature(M, WhichCurv)
%CURVATURE Summary of this function goes here
%   Detailed explanation goes here

    if nargin == 1
        WhichCurv = "Mean";
    end

    % Triangles vertices and edges
    V1 = M.VERT(M.TRIV(:, 1), :);
    V2 = M.VERT(M.TRIV(:, 2), :);
    V3 = M.VERT(M.TRIV(:, 3), :);
    E12 = V2 - V1;
    E13 = V3 - V1;
    
    % Triangle normals
    NT = cross(E12, E13, 2);
    NT = NT ./ vecnorm(NT, 2, 2);
    % Vertices normals
    areas = mesh.proc.tri_areas(M);
    P = sparse(M.TRIV(:), [1:M.m 1:M.m 1:M.m], repmat(areas, 3, 1));
    NV = sparse(1:M.n, 1:M.n, 1 ./ sum(P, 2)) * (P * NT);
    NV = NV ./ vecnorm(NV, 2, 2);
    % Triangle vertices normal
    N1 = NV(M.TRIV(:, 1), :);
    N2 = NV(M.TRIV(:, 2), :);
    N3 = NV(M.TRIV(:, 3), :);
    
    % Compute the projections of differences with N1 onto the triangle
    D2N = N2 - N1;
    D2N = D2N - NT .* dot(NT, D2N, 2);
    D3N = N3 - N1;
    D3N = D3N - NT .* dot(NT, D3N, 2);
    
    
    
    G11 = dot(E12, D2N, 2);
    G12 = dot(E12, D3N, 2);
    G21 = dot(E13, D2N, 2);
    G22 = dot(E13, D3N, 2);
    II = [reshape(G11, 1, 1, M.m), reshape(G12, 1, 1, M.m);
          reshape(G21, 1, 1, M.m), reshape(G22, 1, 1, M.m)];
    MinCurv = zeros(M.m, 1);
    MaxCurv = zeros(M.m, 1);
    
    for i = 1:M.m
        l = eig(II(:, :, i));
        MinCurv(i) = l(1);
        MaxCurv(i) = l(2);
    end
    Mean = (MinCurv + MaxCurv) ./ 2;
    Gauss = MinCurv .* MaxCurv;
    
    if lower(WhichCurv) == "mean"
        Curvature = Mean;  % (MinCurv + MaxCurv) / 2;
    elseif lower(WhichCurv) == "gauss"
        Curvature = Gauss; % MinCurv .* MaxCurv;
    else
        error("%s is not a valid curvature type.", WhichCurv);
    end
    
    if nargout > 1
        OnVerts = proc.grad_on_verts(M, Curvature);
        if nargout > 2
            OnVerts(:, 2) = proc.grad_on_verts(M, MinCurv);
        end
        if nargout > 3
            OnVerts(:, 3) = proc.grad_on_verts(M, MaxCurv);
        end
    end
end

