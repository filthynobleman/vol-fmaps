function S = farthest_point_sampling(M, NSamples)
%FARTHEST_POINT_SAMPLING Summary of this function goes here
%   Detailed explanation goes here

    D = inf(M.n, 1);
    S = zeros(NSamples, 1);
    for ii = 1:NSamples
        if ii == 1
            i = randi(M.n);
        else
            [~, i] = max(D);
        end

        S(ii) = i;
        DD = sum((M.VERT - M.VERT(i, :)).^2, 2);
        D = min(D, DD);

    end

end

