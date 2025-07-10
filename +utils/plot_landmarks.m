function plot_landmarks(M, N, LM, LN, Size)

    assert(length(LM) == length(LN));
    if nargin < 5
        Size = 64;
    end

    Colors = rand(length(LM), 3);

    subplot(1, 2, 1);
    utils.plot_scalar_map(M);
    hold on;
    LM = M.VERT(LM, :);
    scatter3(LM(:, 1), LM(:, 2), LM(:, 3), Size, Colors, 'filled');

    subplot(1, 2, 2);
    utils.plot_scalar_map(N);
    hold on;
    LN = N.VERT(LN, :);
    scatter3(LN(:, 1), LN(:, 2), LN(:, 3), Size, Colors, 'filled');

end

