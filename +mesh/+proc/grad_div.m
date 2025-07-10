function [G, D] = grad_div(M)
%GRAD_DIV Summary of this function goes here
%   Detailed explanation goes here

    F = M.TRIV';
    X = M.VERT';
    n = M.n;
    m = M.m;
    
    XF = @(i) X(:, F(i, :));
    Na = cross(XF(2) - XF(1), XF(3) - XF(1));
    amplitude = @(X) sqrt(sum(X.^2));
    A = amplitude(Na) / 2;
    normalize = @(X) X ./ repmat(amplitude(X), [3 1]);
    N = normalize(Na);

    I = []; J = []; V = []; % indexes to build the sparse matrices
    for i=1:3
        % opposite edge e_i indexes
        s = mod(i, 3) + 1;
        t = mod(i + 1, 3) + 1;
        % vector N_f^e_i
        wi = cross(XF(t) - XF(s), N);
        % update the index listing
        I = [I, 1:m];
        J = [J, F(i, :)];
        V = [V, wi];
    end
    
    % Gradient
    dA = spdiags(1 ./ (2 * repmat(A(:), 3, 1)), 0, 3 * m, 3 * m);
    G = dA * sparse([I; I + m; I + 2*m], [J; J; J], V, 3 * m, n);
    
    % Divergence
    dAf = spdiags(2 * repmat(A(:), 3, 1), 0, 3 * m, 3 * m);
    D = G' * dAf;
end

