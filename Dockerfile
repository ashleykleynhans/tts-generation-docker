# Stage 1: Base
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04 as base

ARG TTS_COMMIT=a34f2bf19d488f6a6b2d0601200832388da10613
ARG TORCH_VERSION=2.0.0

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=on \
    SHELL=/bin/bash

# Create workspace working directory
WORKDIR /

# Install Ubuntu packages
RUN apt update && \
    apt -y upgrade && \
    apt install -y --no-install-recommends \
        software-properties-common \
        build-essential \
        python3.10-venv \
        python3-pip \
        python3-tk \
        python3-dev \
        nginx \
        bash \
        dos2unix \
        git \
        ncdu \
        net-tools \
        openssh-server \
        libglib2.0-0 \
        libsm6 \
        libgl1 \
        libxrender1 \
        libxext6 \
        ffmpeg \
        wget \
        curl \
        psmisc \
        rsync \
        vim \
        zip \
        unzip \
        htop \
        screen \
        tmux \
        pkg-config \
        libcairo2-dev \
        libgoogle-perftools4 \
        libtcmalloc-minimal4 \
        apt-transport-https \
        ca-certificates && \
    update-ca-certificates && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

# Set Python
RUN ln -s /usr/bin/python3.10 /usr/bin/python

# Stage 2: Install Web UI and python modules
FROM base as setup

# Create and use the Python venv
RUN python3 -m venv /venv

# Clone the git repo of TTS Generation WebUI and set version
WORKDIR /
RUN git clone https://github.com/rsxdalv/tts-generation-webui.git && \
    cd /tts-generation-webui && \
    git checkout ${TTS_COMMIT}

# Install the Python dependencies for TTS Generation WebUI
WORKDIR /tts-generation-webui
RUN source /venv/bin/activate && \
    pip3 install --no-cache-dir torch==${TORCH_VERSION} torchaudio torchvision --index-url https://download.pytorch.org/whl/cu118 && \
    pip3 install -r requirements.txt && \
    pip3 install -r requirements_audiocraft_only.txt --no-deps && \
    pip3 install -r requirements_audiocraft_deps.txt && \
    pip3 install -r requirements_bark_hubert_quantizer.txt && \
    pip3 install -r requirements_rvc.txt && \
    pip3 install hydra-core==1.3.2 && \
    deactivate

# Install the NodeJS dependencies for the TTS Generation WebUI
RUN curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh && \
    bash nodesource_setup.sh && \
    apt -y install nodejs && \
    cd /tts-generation-webui/react-ui && \
    npm install && \
    npm run build

# Copy configuration files
COPY config.json /tts-generation-webui/config.json
COPY .env /tts-generation-webui/.env

# Install Jupyter, gdown and OhMyRunPod
RUN pip3 install -U --no-cache-dir jupyterlab \
        jupyterlab_widgets \
        ipykernel \
        ipywidgets \
        gdown \
        OhMyRunPod

# Install RunPod File Uploader
RUN curl -sSL https://github.com/kodxana/RunPod-FilleUploader/raw/main/scripts/installer.sh -o installer.sh && \
    chmod +x installer.sh && \
    ./installer.sh

# Install rclone
RUN curl https://rclone.org/install.sh | bash

# Install runpodctl
ARG RUNPODCTL_VERSION="v1.14.2"
RUN wget "https://github.com/runpod/runpodctl/releases/download/${RUNPODCTL_VERSION}/runpodctl-linux-amd64" -O runpodctl && \
    chmod a+x runpodctl && \
    mv runpodctl /usr/local/bin

# Install croc
RUN curl https://getcroc.schollz.com | bash

# Install speedtest CLI
RUN curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash && \
    apt install speedtest

# Remove existing SSH host keys
RUN rm -f /etc/ssh/ssh_host_*

# NGINX Proxy
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/502.html /usr/share/nginx/html/502.html

# Set template version
ENV TEMPLATE_VERSION=2.0.8

# Set the venv path
ENV VENV_PATH="/workspace/venvs/tts-generation-webui"

# Copy the scripts
WORKDIR /
COPY --chmod=755 scripts/* ./

# Start the container
SHELL ["/bin/bash", "--login", "-c"]
CMD [ "/start.sh" ]
