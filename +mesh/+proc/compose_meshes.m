function Composition = compose_meshes(M1, M2, varargin)
%COMPOSE_MESHES Summary of this function goes here
%   Detailed explanation goes here

    Meshes = {M1, M2};
    if nargin > 2
        Meshes = cat(2, Meshes, varargin);
    end
    
    Composition = Meshes{1};
    for i = 2:length(Meshes)
        Composition.VERT = [Composition.VERT; Meshes{i}.VERT];
        Composition.TRIV = [Composition.TRIV; Meshes{i}.TRIV + Composition.n];
        Composition.n = size(Composition.VERT, 1);
        Composition.m = size(Composition.TRIV, 1);
    end
    
    Composition.X = Composition.VERT(:, 1);
    Composition.Y = Composition.VERT(:, 2);
    Composition.Z = Composition.VERT(:, 3);

end

