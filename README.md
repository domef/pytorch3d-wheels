# pytorch3d-wheels
This repository contains some useful tools to build pytorch3d wheels for linux.

## Build wheels

First you need to compile the Docker images that will be used as the environment to build the wheels. You need a different Docker image for each cuda version you need to build the wheels for. To create the cuda-11.8 image:

```
docker build -t pytorch3d_builder:cu118 .
```

Depending on the cuda versions needed you can change the starting image in the Dockerfile and the docker image name accordingly. 

The script `compile_outside.sh` orchestrates the build in the various docker images while the script `compile_inside.sh` is launched inside the docker images and it actually builds the wheels.

Building example:

```
./compile_outside.sh "3.10 3.11 3.12" "2.4.1:118 121 124,2.5.1:118 121 124,2.6.0:118 124" "0.7.7 0.7.8" ./wheels/
```

The input parameters are:
- python versions
- pytorch versions, for each one you can speficy different cuda versions
- pytorch3d versions
- output folder where the wheels will be saved

This will build a wheel for each combination of python, pytorch/cuda and pytorch3d version. In this example 48 wheels will be created.
