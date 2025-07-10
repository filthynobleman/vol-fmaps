function Adj = adj_matrix(M)
%ADJ_MATRIX Summary of this function goes here
%   Detailed explanation goes here

    E = [M.TRIV(:, [1 2]); M.TRIV(:, [2 3]); M.TRIV(:, [3 1])];
    Adj = sparse(E(:, 1), E(:, 2), 1, M.n, M.n);
    Adj = double((Adj + Adj') > 0);
end

