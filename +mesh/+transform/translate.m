function M = translate(M, translation)
%M = TRANSLATE(M, translation)
%   Translate the mesh in the 3-D space by the given 3-D vector.

    M.VERT = M.VERT + translation;
    M.X = M.VERT(:, 1);
    M.Y = M.VERT(:, 2);
    M.Z = M.VERT(:, 3);
end

