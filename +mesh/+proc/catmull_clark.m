function N = catmull_clark(M, NumIterations)
%CATMULL_CLARK Summary of this function goes here
%   Detailed explanation goes here

    for i = 1:NumIterations
        FacePoints = M.VERT(M.TRIV(:, 1), :) + ...
                     M.VERT(M.TRIV(:, 2), :) + ...
                     M.VERT(M.TRIV(:, 3), :);
        FacePoints = FacePoints ./ 3;
        FPIdxs = 1:size(FacePoints, 1);
        Edges = [M.TRIV(:, [1 2]);
                 M.TRIV(:, [2 3]);
                 M.TRIV(:, [3 1])];
        Edges = sort(Edges, 2);
        Edges = unique(Edges, 'rows');
        EdgePoints = M.VERT(Edges(:, 1), :) + M.VERT(Edges(:, 2), :);
        EdgePoints = EdgePoints ./ 2;
        EPIdxs = (1:size(EdgePoints, 1)) + size(FacePoints, 1);
    end


end

