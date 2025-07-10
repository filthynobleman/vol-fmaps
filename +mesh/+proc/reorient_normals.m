function M = reorient_normals(M)
%REORIENT_NORMALS Summary of this function goes here
%   Detailed explanation goes here

    % Get edges
    E = [M.TRIV(:, [1 2]);
         M.TRIV(:, [2 3]);
         M.TRIV(:, [3 1])];
    E = sort(E, 2);

    % Build Edge-to-Triangle map
    % First occurrence of each edge determines the index of the first
    % triangle
    [Eu, EIdx] = unique(E, "rows", "first");
    E2T = mod(EIdx - 1, M.m) + 1;
    % Second occurrence determines second triangle
    [~, EIdx] = unique(E, "rows", "last");
    E2T(:, 2) = mod(EIdx - 1, M.m) + 1;

    % If edge occurs in the correct order in the first triangle, ok
    % Otherwise, flip triangle
    ToFlip = all(Eu == M.TRIV(E2T(:, 1), [1 2]), 2);
    ToFlip = ToFlip | all(Eu == M.TRIV(E2T(:, 1), [2 3]), 2);
    ToFlip = ToFlip | all(Eu == M.TRIV(E2T(:, 1), [3 1]), 2);
    ToFlip = ~ToFlip;
    M.TRIV(E2T(ToFlip, 1), :) = fliplr(M.TRIV(E2T(ToFlip, 1), :));

    % Reverse order for the second triangle
    ToFlip = all(Eu == M.TRIV(E2T(:, 2), [2 1]), 2);
    ToFlip = ToFlip | all(Eu == M.TRIV(E2T(:, 2), [3 2]), 2);
    ToFlip = ToFlip | all(Eu == M.TRIV(E2T(:, 2), [1 3]), 2);
    ToFlip = ~ToFlip;
    M.TRIV(E2T(ToFlip, 2), :) = fliplr(M.TRIV(E2T(ToFlip, 2), :));

end

