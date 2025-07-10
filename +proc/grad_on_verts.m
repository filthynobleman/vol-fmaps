function gradv = grad_on_verts(M, grad)
%gradv = GRAD_ON_VERTS(M, grad)
%Given a gradient grad on the triangles of the mesh M, compute the same
%gradient, applied to the vertices of M.

    A = mesh.proc.tri_areas(M);
    A = repmat(A, 3, 1);
    I = M.TRIV(:);
    J = repmat((1:M.m)', 3, 1);
    P = sparse(I, J, A, M.n, M.m);
    gradv = P * grad;
    gradv = gradv ./ sum(P, 2);

end

