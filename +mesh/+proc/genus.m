function [g, xi] = genus(M)

    % Get num edges
    E = [M.TRIV(:, [1, 2]);
         M.TRIV(:, [2, 3]);
         M.TRIV(:, [3, 1])];
    E = sort(E, 2);
    E = unique(E, "rows");
    E = size(E, 1);

    % Get Euler characteristic
    xi = M.n - E + M.m;

    % Get genus
    g = (2 - xi) / 2;

end

