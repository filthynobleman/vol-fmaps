function D = heat_geodesics(M, Source, t)
%HEAT_GEODESICS Summary of this function goes here
%   Detailed explanation goes here

    if ~isfield(M, 'S') || ~isfield(M, 'A')
        [M.S, ~, M.A] = mesh.proc.FEM_higher(M, 1);
    end
    if ~isfield(M, 'Grad')
        M.Grad = mesh.proc.grad(M);
    end
    if ~isfield(M, 'Div')
        M.Div = mesh.proc.div(M);
    end
        
    if nargin < 3
        E = [M.TRIV(:, [1, 2]); M.TRIV(:, [2, 3]); M.TRIV(:, [3, 1])];
        E = sort(E, 2);
        E = unique(E, 'rows');
        E = M.VERT(E(:, 2), :) - M.VERT(E(:, 1), :);
        E = dot(E, E, 2);
        E = sqrt(E);
        t = mean(E);
        t = t * t;
    end

    DeltaCot = M.A \ M.S;

    Delta = zeros(M.n, length(Source));
    for i = 1:length(Source)
        Delta(Source(i), i) = 1;
    end

    u = (M.A + t * DeltaCot) \ Delta;
    g = M.Grad * u;
    for i = 1:length(Source)
        h = reshape(g(:, i), M.m, 3);
        h = h ./ vecnorm(h, 2, 2);
        g(:, i) = -h(:);
    end
    D = DeltaCot \ (M.Div * g);
    D = D - min(D);

end

