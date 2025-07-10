function G = transfer_3d(Src, Trg, F)
%TRANSFER_3D Summary of this function goes here
%   Detailed explanation goes here

    [~, I, C] = mesh.proc.nearest_surface_point(Src, Trg);
    L = utils.cart2Baryc(Src.VERT, Src.TRIV, I, C);
    L = sparse(repmat((1:Trg.n)', 3, 1), ...
               reshape(Src.TRIV(I, :), 3 * numel(I), 1), ...
               L(:), ...
               Trg.n, Src.n, 3 * numel(I));

    G = L * F;

end

