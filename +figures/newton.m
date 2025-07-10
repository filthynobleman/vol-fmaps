%% Clear the workspace
clear all
close all
clc


%% Reproducibility
Seed = 0;
rng(Seed);


%% Parameters
DataDir = "./data/";
OutDir = "./results/newton";
MeshName = "armadillo03";

NEigs = 40;
NEigsFM = 200;
ProdOrder = 2;
NLandmarks = 5;
UseMass = false;


%% Load the meshes
fprintf("Loading the meshes... ");
tic;
Src = tetmesh.io.load_mesh(sprintf("%s/%s-rest.mesh", DataDir, MeshName));
Trg = tetmesh.io.load_mesh(sprintf("%s/%s-result.mesh", DataDir, MeshName));
toc;


%% Surface
fprintf("Extracting the surface... ");
tic;
Src.Surf = tetmesh.utils.extract_surface(Src);
Trg.Surf = tetmesh.utils.extract_surface(Trg);
toc;


%% Landmarks
fprintf("Extracting the landmarks... ");
tic;
Src.LM = mesh.proc.farthest_point_sampling(Src.Surf, NLandmarks);
Src.LM = Src.Surf.Pi(Src.LM);
Trg.LM = Src.LM;
toc;


%% LBO decomposition
fprintf("Computing the eigenfunctions... ");
tic;
Src = lbo_decomposition(Src, NEigsFM, UseMass);
Trg = lbo_decomposition(Trg, NEigsFM, UseMass);
toc;


%% Orthoprods
fprintf("Computing the orthogonal eigenproducts... ");
tic;
Src = orthoprods(Src, NEigs, ProdOrder, UseMass);
Trg = orthoprods(Trg, NEigs, ProdOrder, UseMass);
toc;


%% Compute map
fprintf("Computing the functional map... ");
tic;
ZOParams.k_init = 20;
ZOParams.k_step = 5;
ZOParams.k_final = NEigs;
[~, Pi] = zoomout(Src, Trg, ...
                  Src.LM, Trg.LM, ...
                  ZOParams, NEigsFM, ...
                  UseMass);
ZOParams.k_init = NEigs;
QSize = min(size(Src.QPhi, 2), size(Trg.QPhi, 2));
ZOParams.k_final = QSize;
if UseMass
    [~, C] = zoomOut_refine_ortho_mass(Trg.QPhi, ...
                                       Src.QPhi, ...
                                       Pi, Trg.A, ZOParams);
else
    [~, C] = zoomOut_refine_ortho(Trg.QPhi, ...
                                  Src.QPhi, ...
                                  Pi, ZOParams);
end
Pi = flann_search(Src.QPhi(:, 1:QSize)', ...
                  C' * Trg.QPhi(:, 1:QSize)');
toc;


%% Plot
Fig = figure;
Fig.WindowState = 'maximized';


RGBS = utils.rescale(Src.VERT, 0, 1, 1);
if UseMass
    RGBT = utils.rescale(Trg.QPhi(:, 1:QSize) * (C * (Src.QPhi(:, 1:QSize)' * (Src.A * Src.VERT))), 0, 1, 1);
else
    RGBT = utils.rescale(Trg.QPhi(:, 1:QSize) * (C * (Src.QPhi(:, 1:QSize)' * Src.VERT)), 0, 1, 1);
end


subplot(1, 3, 1);
utils.plot_rgb_map(Src.Surf, RGBS(Src.Surf.Pi, :), 'faceted');
title("Source");

subplot(1, 3, 2)
utils.plot_rgb_map(Trg.Surf, RGBS(Trg.Surf.Pi, :), 'faceted');
title("Ground truth");

subplot(1, 3, 3)
utils.plot_rgb_map(Trg.Surf, RGBT(Trg.Surf.Pi, :), 'faceted');
title("Transfer");


%% Export
if ~exist(OutDir, 'dir')
    mkdir(OutDir);
end

ZVals = linspace(min(Src.VERT(:, 3)) - eps, max(Src.VERT(:, 3)) + eps, 10);
for i = 1:length(ZVals)
    Tmp = tetmesh.proc.cut(Src, Src.VERT(:, 3) > ZVals(i));
    Tmp.Surf = tetmesh.utils.extract_surface(Tmp);

    mesh.io.write_ply(sprintf("%s/src-%02d.ply", OutDir, i), Tmp.Surf);
    fid = fopen(sprintf("%s/src-coords-%02d.txt", OutDir, i), 'w');
    fprintf(fid, "%f %f %f\n", RGBS(Tmp.Pi(Tmp.Surf.Pi), :)');
    fclose(fid);


    Tmp = tetmesh.proc.cut(Trg, Tmp.Pi);
    Tmp.Surf = tetmesh.utils.extract_surface(Tmp);

    mesh.io.write_ply(sprintf("%s/trg-%02d.ply", OutDir, i), Tmp.Surf);
    fid = fopen(sprintf("%s/trg-coords-%02d.txt", OutDir, i), 'w');
    fprintf(fid, "%f %f %f\n", RGBS(Tmp.Pi(Tmp.Surf.Pi), :)');
    fclose(fid);

    fid = fopen(sprintf("%s/fmap-coords-%02d.txt", OutDir, i), 'w');
    fprintf(fid, "%f %f %f\n", RGBT(Tmp.Pi(Tmp.Surf.Pi), :)');
    fclose(fid);
end























































