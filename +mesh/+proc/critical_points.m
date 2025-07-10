function S = critical_points(M, Phi)

    % Get all unique directed edges
    E = [M.TRIV(:, [1, 2]);     % E1
         M.TRIV(:, [1, 3]);     % E2
         M.TRIV(:, [2, 3])];    % E3
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

