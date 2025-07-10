function D = dijkstra_pairs(M, V1, V2)
%DIJKSTRA_PAIRS Summary of this function goes here
%   Detailed explanation goes here

    if nargin == 3
        V1 = [V1(:), V2(:)];
    else
        if size(V1, 2) ~= 2
            V1 = V1';
        end
    end

    E = [M.TRIV(:, [1 2]);
         M.TRIV(:, [1 3]);
         M.TRIV(:, [2 3])];
    E = sort(E, 2);
    E = int32(unique(E, 'rows'));
    E = [E; fliplr(E)];
    E = sortrows(E);

    D = mexutils.mex_astar_pairs_parallel(M.VERT', E' - 1, int32(V1 - 1)');

end

