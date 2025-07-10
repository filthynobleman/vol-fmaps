function [N, idxs] = cut_mesh(M, tokeep)
%CUT_MESH Summary of this function goes here
%   Detailed explanation goes here
    
    if islogical(tokeep)
        tokeep = find(tokeep);
    end
    
    N.TRIV = M.TRIV((all(ismember(M.TRIV, tokeep), 2)), :);
    N.m = size(N.TRIV, 1);
    
    N.VERT = M.VERT(tokeep, :);
    N.X = N.VERT(:, 1);
    N.Y = N.VERT(:, 2);
    N.Z = N.VERT(:, 3);
    N.n = size(N.VERT, 1);
    
    p = zeros(N.n, 1);
    p(tokeep) = 1:N.n;
    
    N.TRIV = p(N.TRIV);
    
    N.Idx = tokeep;
    N.Area = sum(mesh.proc.tri_areas(N));
    
    if isfield(M, 'PotentialIdx')
        N.PotentialIdx = M.PotentialIdx(N.Idx);
    else
        N.PotentialIdx = N.Idx;
    end
    
    idxs = N.Idx;
end

