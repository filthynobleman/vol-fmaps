function M = composed_mesh(varargin)
%COMPOSED_MESH Summary of this function goes here
%   Detailed explanation goes here


    if nargin == 0
        error("At least an input mesh is needed.");
    end
    
    M = varargin{1};
    for i = 2:nargin
        N = varargin{i};
        M.VERT = [M.VERT; N.VERT];
        M.TRIV = [M.TRIV; N.TRIV + M.n];
        M.n = M.n + N.n;
        M.m = M.m + N.m;
    end
    
    
    M.X = M.VERT(:, 1);
    M.Y = M.VERT(:, 2);
    M.Z = M.VERT(:, 3);
end

