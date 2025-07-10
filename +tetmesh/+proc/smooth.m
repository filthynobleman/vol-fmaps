function M = smooth(M, NIters)

    for i = 1:NIters
        M.VERT = M.VERT + 1e-6 .* (M.A \ (M.S * M.VERT));
        M.VERT = M.VERT - 1e-6 .* (M.A \ (M.S * M.VERT));
    end

end

