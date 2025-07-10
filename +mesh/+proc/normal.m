function [N, NVert] = normal(M)
%NORMAL Summary of this function goes here
%   Detailed explanation goes here

    E = M.TRIV(:, [1 2]);
    E12 = M.VERT(E(:, 2), :) - M.VERT(E(:, 1), :);
    E = M.TRIV(:, [2 3]);
    E23 = M.VERT(E(:, 2), :) - M.VERT(E(:, 1), :);
    E = M.TRIV(:, [3 1]);
    E31 = M.VERT(E(:, 2), :) - M.VERT(E(:, 1), :);
    
    
    N = cross(E12, - E31, 2);
    N = N + cross(E23, -E12, 2);
    N = N + cross(E31, -E23, 2);
    
    P = sparse(M.TRIV(:), [1:M.m 1:M.m 1:M.m], 1);
    NVert = P * N;
    
    N = N ./ vecnorm(N, 2, 2);
    NVert = NVert ./ vecnorm(NVert, 2, 2);
end

