function T2V = tet2verts(M)
%TET2VERTS Summary of this function goes here
%   Detailed explanation goes here

    I = M.TETS(:);
    J = repmat((1:M.m)', 4, 1);
    V = repmat(tetmesh.proc.tet_vols(M), 4, 1);

    T2V = sparse(I, J, V, M.n, M.m, length(V));
    T2V = T2V ./ sum(T2V, 2);


end

