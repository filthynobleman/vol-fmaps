function D = estimate_diameter(M, NSamples)
%ESTIMATE_DIAMETER Summary of this function goes here
%   Detailed explanation goes here

    Samples = mesh.proc.farthest_point_sampling(M, NSamples);

    E = [M.TRIV(:, [1 2]);
         M.TRIV(:, [1 3]);
         M.TRIV(:, [2 3])];
    E = sort(E, 2);
    E = int32(unique(E, 'rows'));
    E = [E; fliplr(E)];
    E = sortrows(E);

    D = mexutils.mex_estimate_diameter(M.VERT', E' - 1, int32(Samples(:) - 1));

end

