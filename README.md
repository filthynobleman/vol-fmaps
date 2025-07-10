# Volumetric Functional Maps

This repository contains the implementation of the volumetric functional maps pipeline described in [the homonymous paper](https://arxiv.org/abs/2506.13212).  


## How to

### Requirements
In order to run this project, you need MATLAB and a working C++ compiler that is compatible with MATLAB for MEX files compilation.

### Preparing the environment
The codebase contains MEX functions that require extra dependencies. Please, be sure to close the repository with the following command
```
git clone --recursive https://github.com/filthynobleman/vol-fmaps.git
```
**or** to run
```
git submodule update --init --recursive --remote
```
after cloning.  

Some of the MATLAB dependencies are located in folders that are not packaged. In order to access such dependencies, run in the MATLAB shell the command
```
prepare.init_path
```

The repository comes with precompiled MEX files for Windows. If you are using a different OS, or if the precompiled files are not working, you can compile them running in the MATLAB shell the command
```
prepare.compile_mex
```

## Examples

The repository contains the code for reproducing some of the figures contained in the paper.  
Please, refer to the content of the folder `+figures` for the available examples.