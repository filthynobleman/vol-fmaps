function [S, A] = laplacian(M, CorrTerm)
%LAPLACIAN Summary of this function goes here
%   Detailed explanation goes here

    % Mass matrix
    A = sparse(1:M.n, 1:M.n, tetmesh.proc.vert_mass(M), M.n, M.n, M.n);

    % Stiffness matrix
    SI = zeros(4 * M.m, 1);
    SJ = zeros(4 * M.m, 1);
    SV = zeros(4 * M.m, 1);
    for i = 1:4
        % Get indices of other vertices in tets
        j = mod(i, 4) + 1;
        k = mod(j, 4) + 1;
        l = mod(k, 4) + 1;

        % Current edge is ij
        Eij = M.VERT(M.TETS(:, j), :) - M.VERT(M.TETS(:, i), :);
        Eij = Eij ./ vecnorm(Eij, 2, 2);
        
        % Get length of edge kl
        Ekl = M.VERT(M.TETS(:, l), :) - M.VERT(M.TETS(:, k), :);
        Lkl = vecnorm(Ekl, 2, 2);
        Ekl = Ekl ./ Lkl;

        % Normal of Tikl
        Eki = M.VERT(M.TETS(:, i), :) - M.VERT(M.TETS(:, k), :);
        Eki = Eki ./ vecnorm(Eki, 2, 2);
        Nikl = cross(Ekl, Eki, 2);
%         Nikl = Nikl ./ vecnorm(Nikl, 2, 2);

        % Normal of Tjlk
        Ekj = M.VERT(M.TETS(:, j), :) - M.VERT(M.TETS(:, k), :);
        Ekj = Ekj ./ vecnorm(Ekj, 2, 2);
        Njlk = -cross(Ekj, Ekl, 2);
%         Njlk = Njlk ./ vecnorm(Njlk, 2, 2);


        % Get angle
        V = acos(dot(Nikl, Njlk, 2));
        SV(((i - 1) * M.m + 1):(i * M.m)) = max(Lkl .* cot(V), 1e-10);

        % Get indices
        SI(((i - 1) * M.m + 1):(i * M.m)) = M.TETS(:, i);
        SJ(((i - 1) * M.m + 1):(i * M.m)) = M.TETS(:, j);
    end
    % Create matrix ensuring symmetry
    S = sparse([SI; SJ], [SJ; SI], [SV; SV] ./ 6, M.n, M.n);
    % Diagonal is the negated sum of rows
    S = S - sparse(1:M.n, 1:M.n, sum(S));

    if nargin > 1
        S = S + CorrTerm .* speye(M.n);
    end

end

