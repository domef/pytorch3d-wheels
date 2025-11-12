#!/bin/bash

PYTHON_VERSIONS=$1
PYTORCH_CUDA_VERSIONS=$2
PYTORCH3D_VERSIONS=$3
CAPABILITIES=$4
OUTPUT_FOLDER=$5

declare -A CUDA_PYTORCH_VERSIONS
IFS=',' read -r -a TORCH_CUDA_VERSION_ARRAY <<< "$PYTORCH_CUDA_VERSIONS"
for TORCH_CUDA_VERSION in "${TORCH_CUDA_VERSION_ARRAY[@]}"; do
    IFS=':' read -r TORCH_VERSION CUDA_VERSIONS <<< "$TORCH_CUDA_VERSION"
    IFS=' ' read -r -a CUDA_VERSIONS_ARRAY <<< "$CUDA_VERSIONS"
    for CUDA_VERSION in "${CUDA_VERSIONS_ARRAY[@]}"; do
        CUDA_PYTORCH_VERSIONS["$CUDA_VERSION"]+="$TORCH_VERSION "
    done
done

echo "Starting wheel compilation..."
echo "Python versions: $PYTHON_VERSIONS"
echo "PyTorch and CUDA versions mapping:"
for CUDA_VERSION in "${!CUDA_PYTORCH_VERSIONS[@]}"; do
    echo "  CUDA $CUDA_VERSION: PyTorch versions: ${CUDA_PYTORCH_VERSIONS[$CUDA_VERSION]}"
done
echo "PyTorch3D versions: $PYTORCH3D_VERSIONS"
echo "CUDA capabilities: $CAPABILITIES"
echo "Output folder: $OUTPUT_FOLDER"



for CUDA_VERSION in "${!CUDA_PYTORCH_VERSIONS[@]}"; do
    PYTORCH_VERSIONS="${CUDA_PYTORCH_VERSIONS[$CUDA_VERSION]}"
    docker run \
        -it \
        --rm \
        -v .:/builder \
        -v "$OUTPUT_FOLDER":/wheels \
        pytorch3d_builder:cu"$CUDA_VERSION" bash /builder/compile_inside.sh \
        "$PYTHON_VERSIONS" \
        "$PYTORCH_VERSIONS" \
        "$PYTORCH3D_VERSIONS" \
        "$CAPABILITIES" \
        /wheels
done
