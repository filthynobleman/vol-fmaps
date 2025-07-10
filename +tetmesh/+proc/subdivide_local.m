function N = subdivide_local(M, Indices)

    if islogical(Indices)
        LogIndices = Indices;
        Indices = find(Indices);
    else
        LogIndices = false(M.m, 1);
        LogIndices(Indices) = true;
    end

    NI = length(Indices);

    % Get barycenters of tets to subdivide
    V = zeros(NI, 3);
    for i = 1:4
        V = V + M.VERT(M.TETS(Indices, i), :);
    end
    V = 0.25 * V;

    % Get indices of vertices
    I = [M.TETS(Indices, :), (1:NI)' + M.n];

    % Compute new tets
    T1 = [I(:, 1), I(:, 2), I(:, 3), I(:, 5)];
    T2 = [I(:, 1), I(:, 3), I(:, 4), I(:, 5)];
    T3 = [I(:, 2), I(:, 1), I(:, 4), I(:, 5)];
    T4 = [I(:, 3), I(:, 2), I(:, 4), I(:, 5)];

    % Allocate structure
    N.VERT = [M.VERT; V];
    N.TETS = [M.TETS(~LogIndices, :);
              T1; T2; T3; T4];
    N.n = size(N.VERT, 1);
    N.m = size(N.TETS, 1);

end

