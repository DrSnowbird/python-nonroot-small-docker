###################################
#### ---- user: developer ---- ####
###################################
# The build-stage image:
FROM continuumio/miniconda3 AS build

COPY scripts /scripts
COPY certificates /certificates
RUN /scripts/setup_system_certificates.sh

# Install the package as normal:
COPY environment.yml .
RUN conda env create -f environment.yml

# Install conda-pack:
RUN conda install -c conda-forge conda-pack

# Use conda-pack to create a standalone enviornment
# in /venv:
RUN conda-pack -n example -o /tmp/env.tar && \
  mkdir /venv && cd /venv && tar xf /tmp/env.tar && \
  rm /tmp/env.tar

# We've put venv in same path it'll be in final image,
# so now fix up paths:
RUN /venv/bin/conda-unpack

# The runtime-stage image; we can use Debian as the
# base image since the Conda env also includes Python
# for us.
FROM debian:buster AS runtime

###################################
#### ---- user: developer ---- ####
###################################
ENV USER_ID=${USER_ID:-1000}
ENV GROUP_ID=${GROUP_ID:-1000}
ENV USER=${USER:-developer}
ENV HOME=/home/${USER}

COPY scripts /scripts
COPY certificates /certificates
RUN /scripts/setup_system_certificates.sh

ENV LANG C.UTF-8
RUN apt-get update && apt-get install -y --no-install-recommends sudo curl wget unzip ca-certificates && \
    useradd -ms /bin/bash ${USER} && \
    export uid=${USER_ID} gid=${GROUP_ID} && \
    mkdir -p /home/${USER} && \
    mkdir -p /home/${USER}/workspace && \
    mkdir -p /etc/sudoers.d && \
    echo "${USER}:x:${USER_ID}:${GROUP_ID}:${USER},,,:/home/${USER}:/bin/bash" >> /etc/passwd && \
    echo "${USER}:x:${USER_ID}:" >> /etc/group && \
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER} && \
    chmod 0440 /etc/sudoers.d/${USER} && \
    chown -R ${USER}:${USER} /home/${USER} && \
    apt-get autoremove; \
    rm -rf /var/lib/apt/lists/* && \
    echo "vm.max_map_count=262144" | tee -a /etc/sysctl.conf
    
###################################
#### ---- Copy: venv   ---- ####
###################################

# Copy /venv from the previous stage:
COPY --from=build /venv ${HOME}/venv
RUN echo ". \${HOME}/venv/bin/activate" | tee -a ${HOME}/.bashrc
    
########################################
#### ---- Set up NVIDIA-Docker ---- ####
########################################
## ref: https://github.com/NVIDIA/nvidia-docker/wiki/Installation-(Native-GPU-Support)#usage
ENV TOKENIZERS_PARALLELISM=false
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,video,utility

#########################################
##### ---- Docker Entrypoint : ---- #####
#########################################
COPY --chown=${USER}:${USER} docker-entrypoint.sh /
COPY --chown=${USER}:${USER} scripts /scripts
COPY --chown=${USER}:${USER} certificates /certificates
RUN /scripts/setup_system_certificates.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

##################################
#### ---- start user env ---- ####
##################################
USER ${USER}
WORKDIR "$HOME"

#CMD ["/bin/bash"]
CMD ["python3", "-V"]

