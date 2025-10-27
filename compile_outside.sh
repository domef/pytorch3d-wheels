#!/bin/bash

PYTHON_VERSIONS=$1
PYTORCH_CUDA_VERSIONS=$2
PYTORCH3D_VERSIONS=$3
OUTPUT_FOLDER=$4

REPO_ROOT=$(pwd)
mkdir -p "$OUTPUT_FOLDER"
OUTPUT_FOLDER_ABS=$(cd "$OUTPUT_FOLDER" && pwd)

declare -A CUDA_PYTORCH_VERSIONS
IFS=',' read -r -a TORCH_CUDA_VERSION_ARRAY <<< "$PYTORCH_CUDA_VERSIONS"
for TORCH_CUDA_VERSION in "${TORCH_CUDA_VERSION_ARRAY[@]}"; do
    IFS=':' read -r TORCH_VERSION CUDA_VERSIONS <<< "$TORCH_CUDA_VERSION"
    IFS=' ' read -r -a CUDA_VERSIONS_ARRAY <<< "$CUDA_VERSIONS"
    for CUDA_VERSION in "${CUDA_VERSIONS_ARRAY[@]}"; do
        CUDA_PYTORCH_VERSIONS["$CUDA_VERSION"]+="$TORCH_VERSION "
    done
done


for CUDA_VERSION in "${!CUDA_PYTORCH_VERSIONS[@]}"; do
    PYTORCH_VERSIONS="${CUDA_PYTORCH_VERSIONS[$CUDA_VERSION]}"
    docker run \
        --rm \
        -v "$REPO_ROOT":/builder \
        -v "$OUTPUT_FOLDER_ABS":/wheels \
        pytorch3d_builder:cu"$CUDA_VERSION" bash /builder/compile_inside.sh \
        "$PYTHON_VERSIONS" \
        "$PYTORCH_VERSIONS" \
        "$PYTORCH3D_VERSIONS" \
        /wheels
done
