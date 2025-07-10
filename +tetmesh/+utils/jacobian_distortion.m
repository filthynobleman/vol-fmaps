function J = jacobian_distortion(M, V)
%JACOBIAN_DISTORTION Summary of this function goes here
%   Detailed explanation goes here

    J = mexutils.mex_jacobian_distortions(M.VERT', V', int32(M.TETS' - 1));

end

