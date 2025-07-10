function M = orthoprods(M, k, n, UseMass)
%ORTHOPRODS Summary of this function goes here
%   Detailed explanation goes here

    if n == 1
        M.QPhi = M.Phi;
        return;
    end

    if nargin < 4
        UseMass = false;
    end

    % Compute eigenproducs and orthogonalization
    PolyPhi = eigprods(M, k - 1, n, ~UseMass);
    if UseMass
        PPN = diag(PolyPhi' * (M.A * PolyPhi));
        PolyPhi = PolyPhi ./ reshape(PPN, 1, length(PPN));
        PolyPhi = sqrt(M.A) * PolyPhi;
    end
    [M.QPhi, ~] = qr(PolyPhi, 0);
    if UseMass
        M.QPhi = sqrt(M.A) \ M.QPhi;
    end

    % Ensure eigenbasis has same signs
    if UseMass
        Signs = sign(sum(M.QPhi(:, 1:k) .* (M.A * M.Phi(:, 1:k))));
    else
        Signs = sign(sum(M.QPhi(:, 1:k) .* PolyPhi(:, 1:k)));
    end
    Signs = sparse(1:k, 1:k, Signs, k, k, k);
    M.QPhi(:, 1:k) = M.QPhi(:, 1:k) * Signs;


end

