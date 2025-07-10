function N = cut_tets(M, ToKeep)
%CUT Summary of this function goes here
%   Detailed explanation goes here

    if ~islogical(ToKeep)
        Tmp = false(M.m, 1);
        Tmp(ToKeep) = true;
        ToKeep = Tmp;
    end

    % Select tets to keep
    N.TETS = M.TETS(ToKeep, :);
    N.m = size(N.TETS, 1);

    % Find vertices to keep
    N.Pi = unique(N.TETS(:));
    N.VERT = M.VERT(N.Pi, :);
    N.n = size(N.VERT, 1);

    % Remap triangles
    Pi = zeros(M.n, 1);
    Pi(N.Pi) = 1:N.n;
    N.TETS = Pi(N.TETS);


end

