function V = tet_vols(M, Signed)
%TET_VOLS Summary of this function goes here
%   Detailed explanation goes here

    if nargin < 2
        Signed = false;
    end

    L0 = M.VERT(M.TETS(:, 2), :) - M.VERT(M.TETS(:, 1), :);
    L2 = M.VERT(M.TETS(:, 1), :) - M.VERT(M.TETS(:, 3), :);
    L3 = M.VERT(M.TETS(:, 4), :) - M.VERT(M.TETS(:, 1), :);

    V = cross(L2, L0, 2);
    V = dot(V, L3, 2) ./ 6;
    if ~Signed
        V = abs(V);
    end

end

