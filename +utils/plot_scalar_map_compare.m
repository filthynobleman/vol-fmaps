function plot_scalar_map_compare(M, N, FM, FN, cm, shading_opt)

    if nargin < 6
        shading_opt = 'interp';
    end

    if nargin == 2
        subplot(1, 2, 1);
        utils.plot_scalar_map(M);
        shading(shading_opt);
        subplot(1, 2, 2);
        utils.plot_scalar_map(N);
        shading(shading_opt);
    else
        subplot(1, 2, 1);
        utils.plot_scalar_map(M, FM, cm);
        shading(shading_opt);
        subplot(1, 2, 2);
        utils.plot_scalar_map(N, FN, cm);
        shading(shading_opt);
    end

end

