function S = euclidean_fps(V, NSamples)
%EUCLIDEAN_FPS Summary of this function goes here
%   Detailed explanation goes here

    S = zeros(NSamples, 1);

    S(1) = 1;
    D = vecnorm(V - V(S(1), :), 2, 2);
    for k = 2:NSamples
        [~, S(k)] = max(D);
        DD = vecnorm(V - V(S(k), :), 2, 2);
        D = min(D, DD);
    end

end

