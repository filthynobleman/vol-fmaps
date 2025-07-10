function Mesh = gen_plane(N, M)
%GEN_PLANE Summary of this function goes here
%   Detailed explanation goes here

    if nargin < 2
        M = N;
    end
    
    
    x = linspace(0, 1, N);
    y = linspace(0, 1, M);
    [X, Y] = meshgrid(x, y);
    I = (1:(N * M))';
    T1 = [I, (I + 1), (I + M)];
    RM1 = union((M:M:length(I)), (((N-1)*M+1):length(I)));
    T1(RM1, :) = [];
    T2 = [I, (I + M), (I + M - 1)];
    RM2 = union((1:M:length(I)), (((N-1)*M+1):length(I)));
    T2(RM2, :) = [];
    
    
    Mesh.VERT = [X(:), Y(:), zeros(N * M, 1)];
    Mesh.TRIV = [T1; T2];
    Mesh.n = size(Mesh.VERT, 1);
    Mesh.m = size(Mesh.TRIV, 1);
    Mesh.X = X(:);
    Mesh.Y = Y(:);
    Mesh.Z = zeros(N * M, 1);

end

