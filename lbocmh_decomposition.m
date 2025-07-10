function M = lbocmh_decomposition(M, BSize, UseMass)
%LBO_DECOMPOSITION Summary of this function goes here
%   Detailed explanation goes here

    if nargin == 2
        UseMass = false;
    end

    M = lbo_decomposition(M, BSize, UseMass);

    for i = 1:3
        if UseMass
            a = M.Phi' * (M.A * M.VERT(:, i));
        else
            a = M.Phi' * M.VERT(:, i);
        end
        b = M.VERT(:, i) - M.Phi * a;
        if norm(b) >= 1e-6
            M.Phi = [M.Phi, b ./ norm(b)];
        end
    end

end

