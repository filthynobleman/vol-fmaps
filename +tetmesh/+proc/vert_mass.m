function VM = vert_mass(M)
%VERT_MASS Summary of this function goes here
%   Detailed explanation goes here

    VT = repmat(tetmesh.proc.tet_vols(M), 4, 1);
    VM = full(sparse(M.TETS(:), ones(4 * M.m, 1), VT, M.n, 1, 4 * M.m));

    VM = VM ./ 4;
    
    

end

