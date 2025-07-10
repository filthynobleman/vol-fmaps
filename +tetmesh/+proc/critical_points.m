function S = critical_points(M, Phi)
%CRITICAL_POINTS Summary of this function goes here
%   Detailed explanation goes here

    % Find min/max of Phi on each tet
    MinPhi = inf(M.m, 1);
    MaxPhi = -inf(M.m, 1);
    for i = 1:4
        MinPhi = min(MinPhi, Phi(M.TETS(:, i)));
        MaxPhi = max(MaxPhi, Phi(M.TETS(:, i)));
    end

    % Get all unique directed edges
    E = [M.TETS(:, [1, 2]);     % E1
         M.TETS(:, [1, 3]);     % E2
         M.TETS(:, [1, 4]);     % E3
         M.TETS(:, [2, 3]);     % E4
         M.TETS(:, [2, 4]);     % E5
         M.TETS(:, [3, 4])];    % E6
    E = sort(E, 2);
    E = unique(E, "rows");
    E = [E; fliplr(E)];
    E = sortrows(E);

    % Count neighbors
    [NN, NNV] = groupcounts(E(:, 1));

    % Phi-relation on edge
    Phi12 = Phi(E(:, 1)) < Phi(E(:, 2));

    % Determine if local minimum
    NNMin = sparse(E(:, 1), ones(size(E, 1), 1), double(Phi12), M.n, 1);
    NNMin = full(NNMin);
    NNMin = NNMin == NN(NNV);

    % Determine if local maximum
    NNMax = sparse(E(:, 1), ones(size(E, 1), 1), 1 - double(Phi12), M.n, 1);
    NNMax = full(NNMax);
    NNMax = NNMax == NN(NNV);

    % Or
    S = find(NNMin | NNMax);

end

