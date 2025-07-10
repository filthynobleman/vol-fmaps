function [C, Pi, PhiS, PhiT] = zoomout_cmh(Src, Trg, SrcLM, TrgLM, Params, NEigsFM, UseMass)

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

    PhiS = Src.Phi(:, 1:Params.k_final-3);
    PhiT = Trg.Phi(:, 1:Params.k_final-3);
    for i = 1:3
        if UseMass
            a = PhiS' * (Src.A * Src.VERT(:, i));
        else
            a = PhiS' * Src.VERT(:, i);
        end
        b = Src.VERT(:, i) - PhiS * a;
        if UseMass
            NormB = sqrt(b' * (Src.A * b));
        else
            NormB = norm(b);
        end
        if NormB > 1e-6
            PhiS = [PhiS, b ./ NormB];
        end

        if UseMass
            a = PhiT' * (Trg.A * Trg.VERT(:, i));
        else
            a = PhiT' * Trg.VERT(:, i);
        end
        b = Trg.VERT(:, i) - PhiT * a;
        if UseMass
            NormB = sqrt(b' * (Trg.A * b));
        else
            NormB = norm(b);
        end
        if NormB > 1e-6
            PhiT = [PhiT, b ./ NormB];
        end
    end
    if size(PhiS, 2) < Params.k_final
        ND = Params.k_final - size(PhiS, 2);
        PhiS = [PhiS, Src.Phi(:, Params.k_final-2:Params.k_final-3+ND)];
    end
    if size(PhiT, 2) < Params.k_final
        ND = Params.k_final - size(PhiT, 2);
        PhiT = [PhiT, Trg.Phi(:, Params.k_final-2:Params.k_final-3+ND)];
    end


    Pi = flann_search(Src.Phi(:, 1:Params.k_init)', ...
                      C' * Trg.Phi(:, 1:Params.k_init)');
    [Pi, C] = zoomOut_refine(PhiT, PhiS, Pi, Params);

    if nargout == 2
        Pi = flann_search(PhiS', ...
                          C' * PhiT');
    end



end

