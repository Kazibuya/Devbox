#!/bin/bash
set -e

apt-get update -y
apt-get install -y \
  podman \
  python3-pip \
  git \
  curl \
  zsh \
  valac \
  libglib2.0-dev \
  glib-networking \
  libsm6 \
  libxt6

pip3 install ansible molecule molecule-plugins

su - ubuntu -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'

su - ubuntu -c 'git clone https://gitlab.com/nda-cunh/suprapack.git /home/ubuntu/suprapack && cd /home/ubuntu/suprapack && make install'

su - ubuntu -c 'export PATH="$HOME/.local/bin:$PATH" && suprapack install vim && suprapack install supravim'

echo 'export VIM=~/.local/share/vim' >> /home/ubuntu/.zshrc

ssh-keygen -t ed25519 -C "dev-ec2" -f /home/ubuntu/.ssh/id_ed25519 -N ""

chown ubuntu:ubuntu /home/ubuntu/.ssh/id_ed25519*

su - ubuntu -c 'git config --global user.name "${git_name}"'
su - ubuntu -c 'git config --global user.email "${git_email}"'

chsh -s $(which zsh) ubuntu
