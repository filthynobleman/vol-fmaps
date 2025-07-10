function K = gaussian_curvature(M)
%GAUSSIAN_CURVATURE Summary of this function goes here
%   Detailed explanation goes here

    I = zeros(3 * M.m, 1);
    J = ones(3 * M.m, 1);
    V = zeros(3 * M.m, 1);

    for j = 1:3
        j1 = mod(j, 3) + 1;
        j2 = mod(j1, 3) + 1;

        E12 = M.VERT(M.TRIV(:, j1), :) - M.VERT(M.TRIV(:, j), :);
        E12 = E12 ./ vecnorm(E12, 2, 2);

        E13 = M.VERT(M.TRIV(:, j2), :) - M.VERT(M.TRIV(:, j), :);
        E13 = E13 ./ vecnorm(E13, 2, 2);

        Theta = acos(dot(E12, E13, 2));
        
        I(((j - 1) * M.m + 1):(j * M.m)) = M.TRIV(:, j);
        V(((j - 1) * M.m + 1):(j * M.m)) = Theta;
    end

    K = 2 * pi - full(sparse(I, J, V, M.n, 1));

end

