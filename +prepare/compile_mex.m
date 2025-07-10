% Move to mex source dir
cd mex_source\

% Compile
mex mex_dijkstra_pairs.cpp
mex mex_astar_pairs.cpp
mex mex_astar_pairs_parallel.cpp
mex mex_estimate_diameter.cpp
mex mex_jacobian_distortions.cpp
mex mex_nearest_surface_point.cpp -I../deps/eigen -I../deps/libigl/include

% Copy compiled files
Files = dir("./");
for i = 1:length(Files)
    if startsWith(Files(i).name, '.')
        continue
    elseif endsWith(Files(i).name, ".cpp")
        continue
    end
    copyfile(Files(i).name, "../+mexutils");
end

% Get back to project root directory
cd ..