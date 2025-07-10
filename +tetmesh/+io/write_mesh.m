function write_mesh(filename, M)

    fid = fopen(filename, 'w');
    if fid < 0
        error("Cannot open %s for writing.", filename);
    end

    fprintf(fid, "MeshVersionFormatted 1\n");
    fprintf(fid, "Dimension 3\n");

    fprintf(fid, "Vertices\n%d\n", M.n);
    fprintf(fid, "%f %f %f 0\n", M.VERT');

    fprintf(fid, "Tetrahedra\n%d\n", M.m);
    fprintf(fid, "%d %d %d %d 0\n", M.TETS');


    fclose(fid);

end

