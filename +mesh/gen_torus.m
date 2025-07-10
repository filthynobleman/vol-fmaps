function M = gen_torus(InRad, OutRad, UBin, VBin)
%GEN_TORUS Summary of this function goes here
%   Detailed explanation goes here

    assert(InRad <= OutRad);
    if nargin < 4
        VBin = UBin;
    end
    
    u = linspace(0, 2 * pi, UBin);
    v = linspace(0, 2 * pi, VBin);
    [U, V] = meshgrid(u, v);
    clear u v
    A = (OutRad - InRad) / 2;
    C = OutRad - A;
    
    X = (C + A .* cos(V)) .* cos(U);
    Y = (C + A .* cos(V)) .* sin(U);
    Z = A .* sin(V);
    
    u = 1:UBin;
    v = 1:VBin;
    [I, J] = meshgrid(u, v);
    
    clear u v
    % (i, j)  - (i, j + 1)
    %   |       /
    % (i + 1, j)
    TI = [I(:), mod(I(:), UBin) + 1, I(:)];
    TJ = [J(:), J(:), mod(J(:), VBin) + 1];
    T1 = sub2ind([UBin, VBin], TI, TJ);
    %           (i - 1, j + 1)
    %       /       |
    % (i, j)  - (i, j + 1)
    TI = [I(:), I(:), mod(I(:) - 2, UBin) + 1];
    TJ = [J(:), mod(J(:), VBin) + 1, mod(J(:), VBin) + 1];
    T2 = sub2ind([UBin, VBin], TI, TJ);
    
    M.X = X(:);
    M.Y = Y(:);
    M.Z = Z(:);
    M.VERT = [M.X, M.Y, M.Z];
    M.TRIV = [T1; T2];
    M.n = UBin * VBin;
    M.m = size(M.TRIV, 1);
    

end

