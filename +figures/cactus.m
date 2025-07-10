%% Clear the workspace
clear all
close all
clc


%% Reproducibility
Seed = 0;
rng(Seed);


%% Parameters
% DataDir = "./data/meshes";
% Name = "camel02";
% SrcName = sprintf("%s-rest", Name);
% TrgName = sprintf("%s-result", Name);
% NEigs = 2000;
DataDir = "./data/";
OutDir = "./results/cactus";
Name = "cactus";
SrcName = sprintf("%sA", Name);
TrgName = sprintf("%sB", Name);
NEigs = 250;


%% Load meshes
fprintf("Loading meshes... ");
tic;
Src = tetmesh.io.load_mesh(sprintf("%s/%s.mesh", DataDir, SrcName));
Trg = tetmesh.io.load_mesh(sprintf("%s/%s.mesh", DataDir, TrgName));
toc;


%% Extract surfaces
fprintf("Extracting surfaces... ");
tic;
Src.Surf = tetmesh.utils.extract_surface(Src);
Trg.Surf = tetmesh.utils.extract_surface(Trg);
toc;

%% Compute scaling factors and rescale
fprintf("Rescaling... ");
tic;
Src.Area = sum(mesh.proc.tri_areas(Src.Surf));
Src.Surf = mesh.transform.normalize(Src.Surf);
Trg.Area = sum(mesh.proc.tri_areas(Trg.Surf));
Trg.Surf = mesh.transform.normalize(Trg.Surf);
Src = tetmesh.transform.scale(Src, 1 / sqrt(Src.Area));
Trg = tetmesh.transform.scale(Trg, 1 / sqrt(Trg.Area));
toc;


%% Eigendecomposition
fprintf("Computing %d eigenfunctions... ", NEigs);
tic;
Src = lbocmh_decomposition(Src, NEigs);
Trg = lbocmh_decomposition(Trg, NEigs);
toc;


%% Reconstruct coordinates
fprintf("Coordinate transfer and distortions... ");
tic;
DJ = zeros(Src.m, 3);
XYZ = Src.Phi * (Src.Phi(Src.Surf.Pi, :) \ Trg.VERT(Trg.Surf.Pi, :));
Recon = Src;
Recon.VERT = XYZ;
% Recon.VERT(Src.Surf.Pi, :) = Trg.Surf.VERT;
Recon.Surf = tetmesh.utils.extract_surface(Recon);
DJ(:, 1) = tetmesh.utils.jacobian_distortion(Src, XYZ);
C = Src.Phi' * Trg.Phi;
XYZ = Src.Phi * (C * (Trg.Phi' * Trg.VERT));
DJ(:, 2) = tetmesh.utils.jacobian_distortion(Src, XYZ);
ReconCMH = Src;
ReconCMH.VERT = XYZ;
% ReconCMH.VERT(Src.Surf.Pi, :) = Trg.Surf.VERT;
ReconCMH.Surf = tetmesh.utils.extract_surface(ReconCMH);
DJ(:, 3) = tetmesh.utils.jacobian_distortion(Src, Trg.VERT);
toc;


%% Export
if ~exist(OutDir, 'dir')
    mkdir(OutDir);
end

% Export surfaces
mesh.io.write_ply(sprintf("%s/src.ply", OutDir), Src.Surf);
mesh.io.write_ply(sprintf("%s/trg.ply", OutDir), Trg.Surf);
mesh.io.write_ply(sprintf("%s/infer.ply", OutDir), Recon.Surf);
mesh.io.write_ply(sprintf("%s/transfer.ply", OutDir), ReconCMH.Surf);

% Cut
Tmp = tetmesh.proc.cut(Src, Src.VERT(:, 1) < 0.77);
Tmp.Surf = tetmesh.utils.extract_surface(Tmp);
mesh.io.write_ply(sprintf("%s/src-cut.ply", OutDir), Tmp.Surf);

[Tmp, TTPi] = tetmesh.proc.cut(Trg, Tmp.Pi);
[Tmp.Surf, TPi] = tetmesh.utils.extract_surface(Tmp);
mesh.io.write_ply(sprintf("%s/trg-cut.ply", OutDir), Tmp.Surf);
dlmwrite(sprintf("%s/trg-cut.txt", OutDir), DJ(TTPi(TPi), 3));

[Tmp, TTPi] = tetmesh.proc.cut(Recon, Tmp.Pi);
[Tmp.Surf, TPi] = tetmesh.utils.extract_surface(Tmp);
mesh.io.write_ply(sprintf("%s/infer-cut.ply", OutDir), Tmp.Surf);
dlmwrite(sprintf("%s/infer-cut.txt", OutDir), DJ(TTPi(TPi), 1));

[Tmp, TTPi] = tetmesh.proc.cut(ReconCMH, Tmp.Pi);
[Tmp.Surf, TPi] = tetmesh.utils.extract_surface(Tmp);
mesh.io.write_ply(sprintf("%s/transfer-cut.ply", OutDir), Tmp.Surf);
dlmwrite(sprintf("%s/transfer-cut.txt", OutDir), DJ(TTPi(TPi), 2));















































