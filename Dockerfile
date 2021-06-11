FROM ubuntu:focal

USER root

# Install base packages
RUN apt update \
    && apt-get install -y --no-install-recommends \
    curl \
    bash-completion \
    less \
    openssh-client \
    software-properties-common \
    python3.8-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf $(which python3.8) $(which python || echo '/usr/local/bin/python') \
    && ln -sf $(which python3.8) $(which python3 || echo '/usr/local/bin/python3')

# Create the docker user, 'zepp'
ARG USER=bram
ARG UID=1000
ARG GID=1000
RUN addgroup --gid ${GID} ${USER} \
 && adduser \
    --disabled-password \
    --gecos ${USER} \
    --gid ${GID} \
    --uid ${UID} \
    ${USER} \
&& usermod -aG sudo ${USER}

WORKDIR /home/${USER}/

# Install dev packages
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    && add-apt-repository -y ppa:kelleyk/emacs \
    && add-apt-repository ppa:git-core/ppa \
    && apt update \
    && apt-get install -y --no-install-recommends \
        git \
        emacs27 \
        nodejs \
        xauth \
        libcanberra-gtk-module \
        libcanberra-gtk3-module \
        sudo \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf $(which python3.8) $(which python || echo '/usr/local/bin/python') \
    && ln -sf $(which python3.8) $(which python3 || echo '/usr/local/bin/python3')

# Install the python packages
COPY requirements.txt ./
RUN PIP_NO_CACHE_DIR=1 \
    PIP_UPGRADE=1 \
    pip install -r requirements.txt

# Allow jupyter to render plotly plots
# RUN jupyter labextension install --no-build \
#         jupyterlab-plotly@4.14.3 \
#         plotlywidget@4.14.3 \
#     && jupyter lab build

COPY --chown=${USER}:${USER} plugin.jupyterlab-settings /home/${USER}/.jupyter/lab/user-settings/@krassowski/plugin.jupyterlab-settings
COPY --chown=${USER}:${USER} .emacs /home/${USER}/.emacs

# Everything below here as USER
USER ${USER}

# Compile the .emacs in userland
RUN emacs --batch -l /home/${USER}/.emacs

ENV SHELL /bin/bash
