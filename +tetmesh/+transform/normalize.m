function M = normalize(M)
%NORMALIZE Summary of this function goes here
%   Detailed explanation goes here

    Vol = sum(tetmesh.proc.tet_vols(M));
    Vol = Vol^(1/3);
    M = tetmesh.transform.scale(M, 1 / Vol);

end

