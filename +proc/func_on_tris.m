function ftri = func_on_tris(M, f)
    
    A = mesh.proc.tri_areas(M);
    one_third = 1 / 3;
    A = one_third .* repmat(A, 3, 1);
    I = repmat((1:M.m)', 3, 1);
    J = M.TRIV(:);
    P = sparse(I, J, A, M.m, M.n);
    ftri = P * f;

    % ftri = sum(f(M.TRIV), 2) ./ 3;
end

