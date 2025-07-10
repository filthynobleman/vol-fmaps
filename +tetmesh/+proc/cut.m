function [N, TPi] = cut(M, ToKeep)
%CUT Summary of this function goes here
%   Detailed explanation goes here

    if ~islogical(ToKeep)
        Tmp = false(M.n, 1);
        Tmp(ToKeep) = true;
        ToKeep = Tmp;
    end

    % Only keep tets with all the vertices in the submesh
    Tmp = all(ToKeep(M.TETS), 2);
    N.TETS = M.TETS(Tmp, :);
    N.m = size(N.TETS, 1);

    % Compute the correspondence
    N.Pi = find(ToKeep);

    % Keep the vertices
    N.VERT = M.VERT(N.Pi, :);
    N.n = size(N.VERT, 1);

    % Remap triangles
    Pi = zeros(M.n, 1);
    Pi(N.Pi) = 1:N.n;
    N.TETS = Pi(N.TETS);

    if nargout == 1
        return;
    end

    TPi = find(Tmp);


end

