function D = estimate_diameter(M, NSamples)
%ESTIMATE_DIAMETER Summary of this function goes here
%   Detailed explanation goes here

    MSurf = tetmesh.utils.extract_surface(M);
    Samples = MSurf.Pi(mesh.proc.farthest_point_sampling(MSurf, NSamples));

    E = [M.TETS(:, [1 2]);
         M.TETS(:, [1 3]);
         M.TETS(:, [1 4]);
         M.TETS(:, [2 3]);
         M.TETS(:, [2 4]);
         M.TETS(:, [3 4])];
    E = sort(E, 2);
    E = int32(unique(E, 'rows'));
    E = [E; fliplr(E)];
    E = sortrows(E);

    D = mexutils.mex_estimate_diameter(M.VERT', E' - 1, int32(Samples - 1));

end

