function [D, I, C] = nearest_surface_point(M, N)
%NEAREST_SURFACE_POINT Summary of this function goes here
%   Detailed explanation goes here

    if isfield(N, 'VERT')
        N = N.VERT;
    end

    [D, I, C] = mexutils.mex_nearest_surface_point(N', M.VERT', int32(M.TRIV' - 1));
    D = sqrt(D);
    I = I + 1;

end

