function [N, Q] = shuffle(M, P)
%N = SHUFFLE(M, P) Applies the given permutation to the vertices of M. The
%mesh is geometrically unchanged.
%
%N = SHUFFLE(M) Applies a random permutation.
%
%[N, Q] = SHUFFLE(-) Also returns the applied permutation.

    if nargin < 1
        error("Not enough input arguments.");
    end
    if nargin < 2
        P = randperm(M.n)';
    end

    N.VERT = M.VERT(P, :);
    PP = sparse(P, 1:M.n, 1, M.n, M.n);
    [row, PP] = find(PP ~= 0);
    [~, row] = sort(row);
    PP = PP(row);
    N.TRIV = PP(M.TRIV);
    N.X = N.VERT(:, 1);
    N.Y = N.VERT(:, 2);
    N.Z = N.VERT(:, 3);
    N.n = size(N.VERT, 1);
    N.m = size(N.TRIV, 1);

    if nargout > 1
        Q = P;
    end

end

