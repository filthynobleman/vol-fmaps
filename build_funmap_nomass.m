function C = build_funmap_nomass(Src, Trg, KSrc, KTrg, SrcLM, TrgLM, DSrc, DTrg)
%C = BUILD_FUNMAP(Src, Trg, KSrc, KTrg, SrcLM, TrgLM) build  a functional
%map which transfer KSrc eigenfunctions of Src to KTrg eigenfunctions of
%Trg. The function requires a set of landmarks for each shape for the
%initialization process.
%
%C = BUILD_FUNMAP(Src, Trg, KSrc, KTrg) Assumes the shapes are in ground
%truth correspondence and automatically infers a set of 5 landmarks.
%
%
% This code implements a basic version of the algorithm described in:
% 
% Informative Descriptor Preservation via Commutativity for Shape Matching,
% Dorian Nogneng and Maks Ovsjanikov, Proc. Eurographics 2017
% 
% This code was written by Etienne Corman, modified by Maks Ovsjanikov and
% adapted to a function by Filippo Maggioli.

    
    if nargin <= 6
        DSrc = KSrc;
        DTrg = KTrg;
    end

    LM = [SrcLM, TrgLM];
    SN = size(Src.Phi, 1);
    TN = size(Trg.Phi, 1);
    
    
    % Compute descriptors
    FCTSrc = [];
    FCTSrc = [FCTSrc, waveKernelSignature(Src.Phi(:, 1:DSrc), Src.Lambda(1:DSrc), Src.A, 200)];
    FCTSrc = [FCTSrc, waveKernelMap(Src.Phi(:, 1:DSrc), Src.Lambda(1:DSrc), Src.A, 200, LM(:, 1))];
    FCTSrc = FCTSrc(:,1:10:end);

    FCTTrg = [];
    FCTTrg = [FCTTrg, waveKernelSignature(Trg.Phi(:, 1:DTrg), Trg.Lambda(1:DTrg), Trg.A, 200)];
    FCTTrg = [FCTTrg, waveKernelMap(Trg.Phi(:, 1:DTrg), Trg.Lambda(1:DTrg), Trg.A, 200, LM(:, 2))];
    FCTTrg = FCTTrg(:,1:10:end);
    
    % Normalization
    no = sqrt(diag(FCTSrc' * Src.A * FCTSrc))';
    FCTSrc = FCTSrc ./ repmat(no, [SN, 1]);
    FCTTrg = FCTTrg ./ repmat(no, [TN, 1]);
    
    
    % Multiplication Operators
    numFct = size(FCTSrc,2);
    OpSrc = cell(numFct, 1);
    OpTrg = cell(numFct, 1);
    for i = 1:numFct
        OpSrc{i} = Src.Phi(:, 1:KSrc) \ (repmat(FCTSrc(:,i), [1, KSrc]) .* Src.Phi(:, 1:KSrc));
        OpTrg{i} = Trg.Phi(:, 1:KTrg) \ (repmat(FCTTrg(:,i), [1, KTrg]) .* Trg.Phi(:, 1:KTrg));
    end

    Fct_src = Src.Phi(:, 1:KSrc) \ FCTSrc;
    Fct_tar = Trg.Phi(:, 1:KTrg) \ FCTTrg;
    
    
    % Fmap Computation
    Dlb = (repmat(Src.Lambda(1:KSrc), [1, KTrg]) - repmat(Trg.Lambda(1:KTrg)', [KSrc, 1])).^2;
    Dlb = Dlb / norm(Dlb, 'fro')^2;
    if isfield(Src, 'TRIV')
        constFct = sign(Src.Phi(1,1) * Trg.Phi(1,1)) * [sqrt(sum(mesh.proc.tri_areas(Trg)) / sum(mesh.proc.tri_areas(Src))); zeros(KTrg - 1, 1)];
    elseif isfield(Src, 'TETS')
        constFct = sign(Src.Phi(1,1) * Trg.Phi(1,1)) * [sqrt(sum(tetmesh.proc.tet_vols(Trg)) / sum(tetmesh.proc.tet_vols(Src))); zeros(KTrg - 1, 1)];
    else
        error("Unrecognized data structure.");
    end

    a = 1e-1; % Descriptors preservation
    b = 1;    % Commutativity with descriptors
    c = 1e-3; % Commutativity with Laplacian 
    funObj = @(F) deal( a * sum(sum((reshape(F, [KTrg, KSrc]) * Fct_src - Fct_tar).^2)) / 2 + b * sum(cell2mat(cellfun(@(X,Y) sum(sum((X*reshape(F, [KTrg,KSrc]) - reshape(F, [KTrg,KSrc])*Y).^2)), OpTrg', OpSrc', 'UniformOutput', false)), 2)/2 + c*sum( (F.^2 .* Dlb(:))/2 ),...
                a*vec((reshape(F, [KTrg,KSrc])*Fct_src - Fct_tar)*Fct_src') + b*sum(cell2mat(cellfun(@(X,Y) vec(X'*(X*reshape(F, [KTrg,KSrc]) - reshape(F, [KTrg,KSrc])*Y) - (X*reshape(F, [KTrg,KSrc]) - reshape(F, [KTrg,KSrc])*Y)*Y'), OpTrg', OpSrc', 'UniformOutput', false)), 2) + c*F.*Dlb(:));
    funProj = @(F) [constFct; F(KTrg+1:end)];

    F_lb = zeros(KTrg*KSrc, 1); F_lb(1) = constFct(1);

    % Compute the optional functional map using a quasi-Newton method.
    options.verbose = 0;
    F_lb = reshape(minConf_PQN(funObj, F_lb, funProj, options), [KTrg,KSrc]);

    %
    [C, ~] = icp_refine(Src.Phi(:, 1:KSrc), Trg.Phi(:, 1:KTrg), F_lb, 5);

    


end

