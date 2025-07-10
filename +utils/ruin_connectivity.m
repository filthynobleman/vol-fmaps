function [V, Pi] = ruin_connectivity(M, Alpha)
%RUIN_CONNECTIVITY Summary of this function goes here
%   Detailed explanation goes here

    % Shuffle triangles
    M.TRIV = M.TRIV(randperm(M.m), :);

    % Vertex to triangle adjacency
    I = repmat(1:M.m, 1, 3)';
    J = M.TRIV(:);
    P = sparse(J, I, 1, M.n, M.m);

    % First triangle of each vertex
    [~, P] = max(P, [], 2);

    % Index of vertex inside the triangle
    I = (1:M.n)';
    It = ones(M.n, 1);
    It(M.TRIV(P, 2) == I) = 2;
    It(M.TRIV(P, 3) == I) = 3;
    It1Idx = sub2ind(size(M.VERT), (1:M.n)', It);
    It = mod(It, 3) + 1;
    It2Idx = sub2ind(size(M.VERT), (1:M.n)', It);
    It = mod(It, 3) + 1;
    It3Idx = sub2ind(size(M.VERT), (1:M.n)', It);

    % Random barycentric coordinates
    L = zeros(M.n, 3);
    L(It1Idx) = 1 - Alpha * rand(M.n, 1);
    Rem = 1 - L(It1Idx);
    L(It2Idx) = Rem .* (0.25 * rand(M.n, 1) + 0.25);
    L(It3Idx) = 1 - L(It1Idx) - L(It2Idx);

    % New vertices coordinates
    V = L(:, 1) .* M.VERT(M.TRIV(P, 1), :) + ...
        L(:, 2) .* M.VERT(M.TRIV(P, 2), :) + ...
        L(:, 3) .* M.VERT(M.TRIV(P, 3), :);

    % Get registration
    if nargout < 2
        return;
    end
    P = [M.TRIV(P, 1);
         M.TRIV(P, 2);
         M.TRIV(P, 3)];
    L = L(:);
    Pi = sparse(repmat((1:M.n)', 3, 1), P, L, M.n, M.n);
    

end