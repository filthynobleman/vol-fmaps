function write_node_ele(filename, M)

    fid = fopen(strcat(filename, ".node"), 'w');
    if fid < 0
        error("Cannot open %s for writing.", strcat(filename, ".node"));
    end

    fprintf(fid, "%d 3 0 0\n", M.n);
    fprintf(fid, "%d %.10f %.10f %.10f\n", [0:(M.n-1); M.VERT']);

    fclose(fid);


    fid = fopen(strcat(filename, ".ele"), 'w');
    if fid < 0
        error("Cannot open %s for writing.", strcat(filename, ".ele"));
    end

    fprintf(fid, "%d 4 0\n", M.m);
    fprintf(fid, "%d %d %d %d %d\n", [0:(M.m-1); M.TETS' - 1]);

    fclose(fid);
end

