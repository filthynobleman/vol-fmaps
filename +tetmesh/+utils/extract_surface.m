function [S, TPi] = extract_surface(M)
%EXTRACT_SURFACE Summary of this function goes here
%   Detailed explanation goes here

    % Identify all the triangles
    T = [M.TETS(:, [1 2 3]);
         M.TETS(:, [3 2 4]);
         M.TETS(:, [3 4 1]);
         M.TETS(:, [1 4 2])];

    % Get unique occurrences of triangles
    Ts = sort(T, 2);
    [~, Tui, TIdx] = unique(Ts, 'rows');

    % Count occurrences
    [TCnt, TGrp] = groupcounts(TIdx);

    % Get only the triangles occurring once (surface triangles)
    TS = fliplr(T(Tui(TGrp(TCnt == 1)), :));

    % Extract the vertex indices
    S.Pi = TS(:);
    S.Pi = unique(S.Pi);

    % Create the matrix of vertices
    S.VERT = M.VERT(S.Pi, :);
    S.n = size(S.VERT, 1);

    % Create the matrix of triangles
    Pi = zeros(M.n, 1);
    Pi(S.Pi) = 1:S.n;
    S.TRIV = Pi(TS);
    S.m = size(S.TRIV, 1);


    if nargout == 1
        return;
    end


    TPi = mod(Tui(TGrp(TCnt == 1)) - 1, M.m) + 1;


end

