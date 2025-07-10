function M = load_mesh(filename)
%LOAD_MESH Summary of this function goes here
%   Detailed explanation goes here

    fid = fopen(filename, 'r');
    if fid < 0
        error("Cannot open %s for reading.", filename);
    end

    % File version
    Version = fscanf(fid, "MeshVersionFormatted %d\n", 1);
    if isempty(Version)
        error("File %s does not contain keyword '%s'", filename, "MeshVersionFormatted");
    end

    % Num dimensions
    NDims = fscanf(fid, "Dimension %d\n", 1);
    if isempty(NDims)
        error("File %s does not contain keyword '%s'", filename, "Dimension");
    end

    % Read number of vertices
    VKeyword = fscanf(fid, "%s\n", 1);
    if VKeyword ~= "Vertices"
        error("File %s does not contain keyword '%s'", filename, "Vertices");
    end
    NVerts = fscanf(fid, "%d\n", 1);

    % Read vertices
    V = fscanf(fid, "%f %f %f %d\n", [4, NVerts])';
    M.VERT = V(:, 1:3);

    % Read number of tets
    TKeyword = fscanf(fid, "%s\n", 1);
    if TKeyword ~= "Tetrahedra"
        if TKeyword == "Triangles"
            NTris = fscanf(fid, "%d\n", 1);
            if NTris ~= 0
                error("File %s contains triangles, which are an unsupported feature.", filename);
            end
            TKeyword = fscanf(fid, "%s\n", 1);
            if TKeyword ~= "Tetrahedra"
                error("File %s does not contain keyword '%s'", filename, "Tetrahedra");
            end
        else
            error("File %s contains unrecognized keyword '%d'.", filename, TKeyword);
        end
    end
    NTets = fscanf(fid, "%d\n", 1);

    % Read tets
    T = fscanf(fid, "%d %d %d %d %d\n", [5, NTets])';
    M.TETS = T(:, 1:4);

    % Extra info
    M.n = size(M.VERT, 1);
    M.m = size(M.TETS, 1);

    

    fclose(fid);

end

