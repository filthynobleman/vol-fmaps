function N = disconnect_patch(M, PatchIdx)
%DISCONNECT_PATCH Summary of this function goes here
%   Detailed explanation goes here

    if islogical(PatchIdx)
        PatchIdx = find(PatchIdx);
    end
    
    % Find boundary vertices on the patch
    PatchBound = patch_boundary(M, PatchIdx);
    
    % Find boundary vertices on complementary
    Complementary = setdiff(1:M.n, PatchIdx);
    CompBound = patch_boundary(M, Complementary);
    
    
    % Delete triangles shared by boundaries
    DeleteIdx = any(ismember(M.TRIV, PatchBound), 2) & ...
                any(ismember(M.TRIV, CompBound), 2);
    N = M;
    N.TRIV(DeleteIdx, :) = [];
    N.m = size(N.TRIV, 1);

end

function Idx = patch_boundary(M, PatchIdx)

    % find boundary edges
    N = mesh.proc.cut_mesh(M, PatchIdx);
    E = [N.TRIV(:, [1 2]);
         N.TRIV(:, [2 3]);
         N.TRIV(:, [3 1])];
    E = sort(E, 2);
    [Eu, Euidx, ~] = unique(E, 'rows');
    E = E(setdiff(1:length(E), Euidx), :);
    Boundary = Eu(~ismember(Eu, E, 'rows'), :);
    
    Idx = unique(N.Idx(Boundary(:)));
    
end