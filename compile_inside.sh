#!/bin/bash

PYTHON_VERSIONS=($1)
PYTORCH_VERSIONS=($2)
PYTORCH3D_VERSIONS=($3)
OUTPUT_FOLDER=$4

CUDA_VERSION=$(nvcc --version | grep "release" | awk '{print $5}' | sed 's/,//')
CUDA_VERSION_COMPACT=${CUDA_VERSION//./}

CAPABILITIES=(50 60 61 62  70 72 75 80 86 89 90)
CUDA_CAPABILITIES=""
for i in "${CAPABILITIES[@]}"; do
    CUDA_CAPABILITIES+="-gencode=arch=compute_$i,code=sm_$i "
done
CUDA_CAPABILITIES+="-gencode=arch=compute_50,code=compute_50"

export CUDA_HOME=/usr/local/cuda-"$CUDA_VERSION"
export NVCC_FLAGS="$CUDA_CAPABILITIES"

eval "$(pyenv init - bash)"

build_wheel() {
    PY=$1
    PYT=$2
    PYT3D=$3
    PYT_COMPACT=${PYT//./}

    if ! pyenv versions --bare | grep -qx "$PY"; then
        pyenv install "$PY"
    fi

    pyenv global $PY
    VENV_NAME=venv_"$PY"_"$PYT"_"$PYT3D"
    /pyenv/shims/python"$PY" -m venv /root/"$VENV_NAME"

    /root/"$VENV_NAME"/bin/pip install -U pip setuptools
    /root/"$VENV_NAME"/bin/pip install torch==$PYT --index-url https://download.pytorch.org/whl/cu"$CUDA_VERSION_COMPACT"
    
    GIT_TAG1="tags/v$PYT3D"
    GIT_TAG2="tags/V$PYT3D"
    cd /root/pytorch3d && git checkout "$GIT_TAG1" || cd /root/pytorch3d && git checkout "$GIT_TAG2" # || exit  1

    WHEEL_VERSION="$PYT3D"+pyt"$PYT_COMPACT"cu"$CUDA_VERSION_COMPACT"

    sed -i "s/__version__ = .*/__version__ = \"$WHEEL_VERSION\"/" /root/pytorch3d/pytorch3d/__init__.py
    cd /root/pytorch3d && /root/"$VENV_NAME"/bin/python setup.py clean && /root/"$VENV_NAME"/bin/python setup.py bdist_wheel
    mv /root/pytorch3d/dist/*whl $OUTPUT_FOLDER
    git reset --hard
}

git clone https://github.com/facebookresearch/pytorch3d.git /root/pytorch3d

for PYTHON_VERSION in "${PYTHON_VERSIONS[@]}"; do
    for PYTORCH_VERSION in "${PYTORCH_VERSIONS[@]}"; do
        for PYTORCH3D_VERSION in "${PYTORCH3D_VERSIONS[@]}"; do
            echo "Building wheel for Python $PYTHON_VERSION, PyTorch $PYTORCH_VERSION, PyTorch3D $PYTORCH3D_VERSION, CUDA $CUDA_VERSION"
            build_wheel "$PYTHON_VERSION" "$PYTORCH_VERSION" "$PYTORCH3D_VERSION"
        done
    done
done
