function M = lbo_decomposition(M, BSize, UseMass)
%LBO_DECOMPOSITION Summary of this function goes here
%   Detailed explanation goes here

    if nargin < 3
        UseMass = false;
    end

    if isfield(M, 'TRIV')
        [M.S, ~, M.A] = mesh.proc.FEM_order_p(M, 1);
    elseif isfield(M, 'TETS')
        [M.S, M.A] = tetmesh.proc.laplacian(M);
    else
        error("Unsupported data structure.");
    end

    if UseMass
        [M.Phi, M.Lambda] = eigs(M.S, M.A, BSize, 'sm');
%         try
%             [M.Phi, M.Lambda] = eigs(M.S, M.A, BSize, 'sm');
%         catch
%             [M.Phi, M.Lambda] = eigs(M.S + 1e-3 .* spdiags(sign(spdiags(M.S, 0)), 0, M.n, M.n), M.A, BSize, 'sm');
%         end
    else
        [M.Phi, M.Lambda] = eigs(M.S, BSize, 'sm');
    end
    M.Lambda = diag(M.Lambda);

end

