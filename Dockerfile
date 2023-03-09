FROM ubuntu:20.04

ENV TZ="Asia/Taipei"
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Advanced Packaging Tools
ARG DEBIAN_FRONTEND="noninteractive"
RUN apt-get update \
 && apt-get upgrade -y \
    azure-cli \
    build-essential \
    curl \
    docker.io \
    git \
    neovim \
    openssl \
    postgresql \
    python3.9 \
    python3.9-dev \
    python3-distutils \
    redis \
    tzdata \
    wget \
 && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
 && apt-get upgrade -y \
    nodejs \
 && wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add - \
 && echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | \
    tee /etc/apt/sources.list.d/mongodb-org-6.0.list \
 && apt-get update \
 && apt-get upgrade -y \
    mongodb-org \
 && rm -rf /var/lib/apt/lists/*

# Posen's dotfiles
RUN git clone https://github.com/Posen2101024/dotfiles.git -b asus /root/.dotfiles \
 && cd /root/.dotfiles \
 && git rebase origin/main \
 && ./install

# Python3.9
RUN curl https://bootstrap.pypa.io/get-pip.py | python3.9
RUN ln -s /usr/bin/python3.9 /usr/local/bin/python
RUN ln -s /usr/bin/python3.9 /usr/local/bin/python3

# Python Virtualenv
RUN pip install --no-cache-dir --upgrade virtualenv virtualenvwrapper
ENV WORKON_HOME="~/envs"
ENV VIRTUALENVWRAPPER_PYTHON="/usr/local/bin/python3"
RUN echo "source $(which virtualenvwrapper.sh)" >> ~/.bash_aliases

# Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# NPM
RUN npm install -g \
    npm@latest \
 && npm cache clean --force

WORKDIR /main
