function [C, Pi] = zoomout(Src, Trg, SrcLM, TrgLM, Params, NEigsFM, UseMass)

    if nargin < 7
        UseMass = false;
    end

    if UseMass
        C = build_funmap(Src, Trg, ...
                         Params.k_init, Params.k_init, ...
                         SrcLM, TrgLM, ...
                         NEigsFM, NEigsFM);
    else
        C = build_funmap_nomass(Src, Trg, ...
                                Params.k_init, Params.k_init, ...
                                SrcLM, TrgLM, ...
                                NEigsFM, NEigsFM);
    end

    Pi = flann_search(Src.Phi(:, 1:Params.k_init)', ...
                      C' * Trg.Phi(:, 1:Params.k_init)');
    [Pi, C] = zoomOut_refine(Trg.Phi, Src.Phi, Pi, Params);

    if nargout == 2
        Pi = flann_search(Src.Phi(:, 1:Params.k_final)', ...
                          C' * Trg.Phi(:, 1:Params.k_final)');
    end



end

