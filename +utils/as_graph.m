function G = as_graph(M)

    if isfield(M, 'TRIV')
        EM = [M.TRIV(:, 1), M.TRIV(:, 2);
              M.TRIV(:, 2), M.TRIV(:, 3);
              M.TRIV(:, 3), M.TRIV(:, 1)];
    elseif isfield(M, 'TETS')
        EM = [M.TETS(:, 1), M.TETS(:, 2);
              M.TETS(:, 1), M.TETS(:, 3);
              M.TETS(:, 1), M.TETS(:, 4);
              M.TETS(:, 2), M.TETS(:, 3);
              M.TETS(:, 2), M.TETS(:, 4);
              M.TETS(:, 3), M.TETS(:, 4)];
    else
        error("Unrecognized data structure.");
    end
    EM = sort(EM, 2);
    EM = unique(EM, "rows");

    W = M.VERT(EM(:, 1), :) - M.VERT(EM(:, 2), :);
    W = vecnorm(W, 2, 2);
    
    ME = fliplr(EM);
    G = graph(EM(:), ME(:), repmat(W, 2, 1));

    DN = M.n - G.numnodes;
    G = addnode(G, DN);
    
end

