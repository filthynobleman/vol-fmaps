function N = subdivide(M, Map)

    % Get edges
    E = [M.TETS(:, [1, 2]);     % E1
         M.TETS(:, [1, 3]);     % E2
         M.TETS(:, [1, 4]);     % E3
         M.TETS(:, [2, 3]);     % E4
         M.TETS(:, [2, 4]);     % E5
         M.TETS(:, [3, 4])];    % E6
    E = sort(E, 2);
    [uE, ~, iE] = unique(E, "rows");

    % Get midpoint vertices
%     V = [0.5 * (M.VERT(uE(:, 1), :) + M.VERT(uE(:, 2), :));
%          0.25 * (M.VERT(M.TETS(:, 1), :) + M.VERT(M.TETS(:, 2), :) + M.VERT(M.TETS(:, 3), :) + M.VERT(M.TETS(:, 4), :))];
    V = 0.5 * (M.VERT(uE(:, 1), :) + M.VERT(uE(:, 2), :));

    % Edge-2-tet mapping
    E2T = repmat((1:M.m)', 4, 1);

    % Partition edges
    E1 = M.n + iE(1:M.m);
    E2 = M.n + iE((M.m + 1):(2 * M.m));
    E3 = M.n + iE((2 * M.m + 1):(3 * M.m));
    E4 = M.n + iE((3 * M.m + 1):(4 * M.m));
    E5 = M.n + iE((4 * M.m + 1):(5 * M.m));
    E6 = M.n + iE((5 * M.m + 1):(6 * M.m));
%     E7 = (1:M.m)' + length(iE);

    % Make new tetrahedra
    T1 = [E1, E3, E2, M.TETS(:, 1)];
    T2 = [E1, E4, E5, M.TETS(:, 2)];
    T3 = [E2, E6, E4, M.TETS(:, 3)];
    T4 = [E3, E5, E6, M.TETS(:, 4)];
    T5 = [E1, E2, E3, E5];
    T6 = [E1, E4, E2, E5];
    T7 = [E2, E3, E5, E6];
    T8 = [E2, E6, E5, E4];
%     T5 = [E1, E2, E3, E7];
%     T6 = [E1, E2, E4, E7];


    N.VERT = [M.VERT; V];
    N.TETS = [T1; T2; T3; T4; T5; T6; T7; T8];
    N.n = size(N.VERT, 1);
    N.m = size(N.TETS, 1);

    if nargin < 2
        Map = false;
    end
    if ~Map
        return;
    end

    I = [(1:M.n)';
         repmat(((M.n + 1):N.n)', 2, 1)];
    J = [(1:M.n)';
         uE(:)];
    V = [ones(M.n, 1);
         0.5 * ones(2 * size(uE, 1), 1)];
    N.Map = sparse(I, J, V, N.n, M.n, length(V));

end

