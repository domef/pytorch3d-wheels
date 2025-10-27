# pytorch3d-wheels
This repository contains some useful tools to build pytorch3d wheels for linux.

## Build wheels

First you need to compile the Docker images that will be used as the environment to build the wheels. You need a different Docker image for each cuda version you need to build the wheels for. The repository now targets CUDA 12.8.0 on Ubuntu 24.04 and pre-installs Python 3.12–3.13. To create the cuda-12.8 image:

```
docker build -t pytorch3d_builder:cu128 .
```

Depending on the cuda versions needed you can change the starting image in the Dockerfile and the docker image name accordingly. 

The script `compile_outside.sh` orchestrates the build in the various docker images while the script `compile_inside.sh` is launched inside the docker images and it actually builds the wheels.

Building example:

```
./compile_outside.sh "3.12 3.13" "2.9.0:128" "0.7.7 0.7.8" ./wheels/
```

The input parameters are:
- python versions
- pytorch versions, for each one you can speficy different cuda versions
- pytorch3d versions
- output folder where the wheels will be saved
This will build a wheel for each combination of python, pytorch/cuda and pytorch3d version. In this example 48 wheels will be created.
You can trigger the `Build Wheels` GitHub Action (manually, on pull requests, pushes to `main`, or by tagging a release) to produce the same matrix in CI. The workflow uploads the wheels as run artifacts and, for tagged builds, attaches them to the corresponding GitHub release.
At the moment the tooling targets PyTorch `2.9.0+cu128`; adjust the matrix only if you introduce new CUDA images and verify the build end-to-end.

## Continuous Integration

All feature work should happen on topic branches. Opening a pull request triggers the `Build Wheels` GitHub Action, which builds the configured wheel matrix to ensure changes compile. The workflow also runs on pushes to `main`, publishing fresh wheels as build artifacts so they are readily available for testing.
