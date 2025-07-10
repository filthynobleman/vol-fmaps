function L = cart2Baryc(V, T, I, P)
%CART2BARYC Summary of this function goes here
%   Detailed explanation goes here

    A = V(T(I, 1), :);
    B = V(T(I, 2), :);
    C = V(T(I, 3), :);

    V0 = B - A;
    V1 = C - A;
    V2 = P - A;

    D00 = dot(V0, V0, 2);
    D01 = dot(V0, V1, 2);
    D11 = dot(V1, V1, 2);
    D20 = dot(V2, V0, 2);
    D21 = dot(V2, V1, 2);

    Den = D00 .* D11 - D01 .* D01;

    L = zeros(size(P));
    L(:, 1) = (D11 .* D20 - D01 .* D21) ./ Den;
    L(:, 2) = (D00 .* D21 - D01 .* D20) ./ Den;
    L(:, 3) = 1 - L(:, 1) - L(:, 2);

end

