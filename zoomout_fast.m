function [C, Pi] = zoomout_fast(Src, Trg, SrcLM, TrgLM, Params, NEigsFM, NSamples)

    C = build_funmap_nomass(Src, Trg, ...
                            Params.k_init, Params.k_init, ...
                            SrcLM, TrgLM, ...
                            NEigsFM, NEigsFM);

    if numel(NSamples) == 1
        if isfield(Src, 'TETS')
            Src.Samples = tetmesh.proc.farthest_point_sampling(Src, NSamples);
            Trg.Samples = tetmesh.proc.farthest_point_sampling(Trg, NSamples);
        elseif isfield(Src, 'TRIV')
            Src.Samples = mesh.proc.farthest_point_sampling(Src, NSamples);
            Trg.Samples = mesh.proc.farthest_point_sampling(Trg, NSamples);
        else
            error("Invalid mesh format.");
        end
    elseif size(NSamples, 2) == 2
        Src.Samples = NSamples(:, 1);
        Trg.Samples = NSamples(:, 2);
    end

    Pi = flann_search(Src.Phi(Src.Samples, 1:Params.k_init)', ...
                      C' * Trg.Phi(Trg.Samples, 1:Params.k_init)');
    [Pi, C] = zoomOut_refine(Trg.Phi(Trg.Samples, :), ...
                             Src.Phi(Src.Samples, :), ...
                             Pi, Params);

    if nargout == 2
        Pi = flann_search(Src.Phi(:, 1:Params.k_final)', ...
                          C' * Trg.Phi(:, 1:Params.k_final)');
    end



end