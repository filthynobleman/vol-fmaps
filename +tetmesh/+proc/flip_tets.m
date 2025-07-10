function M = flip_tets(M)

    M.TETS = M.TETS(:, [1, 3, 2, 4]);

end

