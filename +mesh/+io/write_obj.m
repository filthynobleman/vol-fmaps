function write_obj(filename, M)

    fid = fopen(filename, 'w');
    if fid < 0
        error("Cannot open %s for writing.", filename);
    end

    fprintf(fid, "v %.10f %.10f %.10f\n", M.VERT');
    fprintf(fid, "f %d %d %d\n", M.TRIV');


    fclose(fid);

end

