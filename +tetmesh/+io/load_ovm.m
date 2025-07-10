function M = load_ovm(filename)

    fid = fopen(filename);
    if fid < 0
        error("Cannot open %s for reading.", filename);
    end


    % Header
    Header = fgetl(fid);
    if Header ~= "OVM ASCII"
        fclose(fid);
        error("%s is not a valid OVM file.");
    end

    M = struct();
    while ~isfield(M, 'VERT') || ~isfield(M, 'TETS')

        Keyword = fgetl(fid);
        Count = str2double(fgetl(fid));
        if Keyword == "Vertices"
            M.VERT = fscanf(fid, "%f %f %f\n", [3, Count])';
            M.n = size(M.VERT, 1);
        elseif Keyword == "Polyhedra"
            M.TETS = fscanf(fid, "4 %d %d %d %d\n", [4, Count])';
            M.m = size(M.TETS, 1);
        elseif Keyword == "Edges"
            Edges = fscanf(fid, "%d %d\n", [2, Count])' + 1;
        elseif Keyword == "Faces"
            Faces = fscanf(fid, "3 %d %d %d\n", [3, Count])';
        end
    end

    Odd = mod(Faces, 2) == 1;
    Faces(Odd) = (Faces(Odd) - 1);
    Faces = Faces ./ 2;
    Faces = Faces + 1;
    F1 = Edges(Faces(:, 1), 1);
    F2 = Edges(Faces(:, 1), 2);
    F3 = Edges(Faces(:, 2), 1);
    F4 = Edges(Faces(:, 2), 2);
    Faces = [F1, F2, F3];
    Odd = Odd(:, 1);
    Faces(Odd, [1, 2]) = Faces(Odd, [2, 1]);
    Idx = Faces(:, 3) == F1 | Faces(:, 3) == F2;
    Faces(Idx, 3) = F4(Idx);

    Odd = mod(M.TETS, 2) == 1;
    M.TETS(Odd) = (M.TETS(Odd) - 1);
    M.TETS = M.TETS ./ 2;
    M.TETS = M.TETS + 1;
    F1 = Faces(M.TETS(:, 1), 1);
    F2 = Faces(M.TETS(:, 1), 2);
    F3 = Faces(M.TETS(:, 1), 3);
    F4 = Faces(M.TETS(:, 2), 1);
    F5 = Faces(M.TETS(:, 2), 2);
    F6 = Faces(M.TETS(:, 2), 3);
    M.TETS = [F1, F2, F3, F4];
    Odd = Odd(:, 1);
    M.TETS(Odd, [1, 2]) = M.TETS(Odd, [2, 1]);
    Idx = M.TETS(:, 4) == F1 | M.TETS(:, 4) == F2 | M.TETS(:, 4) == F3;
    M.TETS(Idx, 4) = F5(Idx);
    Idx = M.TETS(:, 4) == F1 | M.TETS(:, 4) == F2 | M.TETS(:, 4) == F3;
    M.TETS(Idx, 4) = F6(Idx);
    

%     Edges = Edges';
%     Edges = Edges(:);
%     Faces = [Edges(Faces(:, 1)), Edges(Faces(:, 2)), Edges(Faces(:, 3))];
%     Faces = Faces';
%     Faces = reshape([Faces; flipud(Faces)], 3, []);
%     Faces = Faces';
%     M.TETS = [Faces(M.TETS(:, 1)), Faces(M.TETS(:, 2)), Faces(M.TETS(:, 3)), Faces(M.TETS(:, 4))];



    fclose(fid);

end

