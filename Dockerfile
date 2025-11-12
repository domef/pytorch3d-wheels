ARG BASE_IMAGE
ARG PYTHON_VERSIONS="3.10 3.11 3.12 3.13"

FROM nvidia/cuda:${BASE_IMAGE}

# Repeat the definition of build argument to make it available in this stage
ARG PYTHON_VERSIONS

ENV DEBIAN_FRONTEND=noninteractive
ENV PYENV_ROOT="/pyenv"
ENV PATH="$PYENV_ROOT/bin:$PATH"

RUN apt-get update -y \
    && apt-get install -y \
    make \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    curl \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    python3-openssl \
    git \
    libxml2-dev \
    libxmlsec1-dev \
    && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://pyenv.run | bash
RUN eval "$(pyenv init -)"
RUN pyenv install ${PYTHON_VERSIONS}
