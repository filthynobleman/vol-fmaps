function M = load_tet(Filename)
%LOAD_TET Summary of this function goes here
%   Detailed explanation goes here

    fid = fopen(Filename, 'r');
    if fid < 0
        error("Cannot open %s for reading.", Filename);
    end

    % Read header
    Line = fgetl(fid);
    [NVerts, Cnt] = sscanf(Line, "%d vertices\n", 1);
    if Cnt ~= 1
        fclose(fid);
        error("%s has not vertex count header.", Filename);
    end
    Line = fgetl(fid);
    if contains(Line, "inner tets")
        [NTets, Cnt] = sscanf(Line, "%d inner tets\n", 1);
        if Cnt ~= 1
            fclose(fid);
            error("%s has not inner tets count header.", Filename);
        end
        Line = fgetl(fid);
        [NOTets, Cnt]= sscanf(Line, "%d outer tets\n", 1);
        if Cnt ~= 1
            warning("%s has not outer tets count header.", Filename);
        elseif NOTets ~= 0
            warning("%s has %d outer tets.", Filename, NOTets);
        end
    else
        [NTets, Cnt] = sscanf(Line, "%d tets\n", 1);
        if Cnt ~= 1
            fclose(fid);
            error("%s has not inner tets count header.", Filename);
        end
    end

    M.n = NVerts;
    M.m = NTets;

    % Read vertices
    M.VERT = fscanf(fid, "%f %f %f\n", [3, M.n])';

    % Read tets
    M.TETS = fscanf(fid, "4 %d %d %d %d\n", [4, M.m])';

    % Ensure 1-indexing
    if min(M.TETS, [], 'all') == 0
        M.TETS = M.TETS + 1;
    end


    fclose(fid);

end

