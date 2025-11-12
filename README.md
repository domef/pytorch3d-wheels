# pytorch3d-wheels
This repository contains some useful tools to build pytorch3d wheels for linux.

## Build wheels

First you need to compile the Docker images that will be used as the environment to build the wheels. You need a different Docker image for each cuda version you need to build the wheels for. Example for creating images for various cuda versions:

```
# Build docker image for cuda 11.8
docker build \
    --build-arg BASE_IMAGE=11.8.0-cudnn8-devel-ubuntu22.04  \
    --build-arg PYTHON_VERSIONS="3.10 3.11 3.12 3.13" \
    -t pytorch3d_builder:cu118 .

# Build docker image for cuda 12.1
docker build \
  --build-arg BASE_IMAGE="12.4.1-cudnn-devel-ubuntu22.04" \
  --build-arg PYTHON_VERSIONS="3.10 3.11 3.12 3.13" \
  -t pytorch3d_builder:cu124 .

# Build docker image for cuda 12.4
docker build \
  --build-arg BASE_IMAGE="12.8.1-cudnn-devel-ubuntu24.04" \
  --build-arg PYTHON_VERSIONS="3.10 3.11 3.12 3.13" \
  -t pytorch3d_builder:cu128 .

# Build docker image for cuda 13.0
docker build \
  --build-arg BASE_IMAGE="13.0.2-cudnn-devel-ubuntu24.04" \
  --build-arg PYTHON_VERSIONS="3.10 3.11 3.12 3.13" \
  -t pytorch3d_builder:cu130 .
```

The script `compile_outside.sh` orchestrates the build in the various docker images while the script `compile_inside.sh` is launched inside the docker images and it actually builds the wheels.

Building example:

```
./compile_outside.sh "3.10 3.11 3.12 3.13" "2.4.1:118 121 124,2.5.1:118 121 124,2.6.0:118 124" "0.7.7 0.7.8" "50 60 61 62 70 72 75 80 86 89 90 120 121" ./wheels/
```

The input parameters are:
- python versions
- pytorch versions, for each one you can speficy different cuda versions
- pytorch3d versions
- cuda capabilities
- output folder where the wheels will be saved

This will build a wheel for each combination of python, pytorch/cuda and pytorch3d version.
