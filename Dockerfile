FROM ubuntu:16.04

RUN \
 apt-get update \
 && apt-get install -y apt-transport-https \
 && apt-get install -y apt-utils \
 && apt-get install -y software-properties-common \
 && apt-get install -y python-software-properties \
 && apt-get install -y curl \
 && apt-get install -y wget \
 && apt-get install -y vim \
 && apt-get install -y git \
 && apt-get install -y zip \
 && apt-get install -y python-dev \
 && apt-get install -y python-pip \
 && apt-get install -y python3-dev \
 && apt-get install -y python3-pip \
&& apt-get install -y daemontools

WORKDIR /root

RUN apt-get install -y default-jdk

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/


# install nodejs, utf8 locale
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install npm nodejs nodejs-legacy wget locales git

# libav-tools for matplotlib anim
RUN apt-get update && \
    apt-get install -y --no-install-recommends libav-tools && \
    apt-get clean
#    rm -rf /var/lib/apt/lists/*

# Install JupyterHub dependencies
RUN npm install -g configurable-http-proxy && rm -rf ~/.npm

WORKDIR /root

# Install Python with conda
RUN wget -q https://repo.continuum.io/miniconda/Miniconda3-4.3.11-Linux-x86_64.sh -O /tmp/miniconda.sh  && \
    echo '1924c8d9ec0abf09005aa03425e9ab1a */tmp/miniconda.sh' | md5sum -c - && \
    bash /tmp/miniconda.sh -f -b -p /opt/conda && \
    /opt/conda/bin/conda install --yes python=3.5 sqlalchemy tornado jinja2 traitlets requests pip && \
    /opt/conda/bin/pip install --upgrade pip && \
    rm /tmp/miniconda.sh

ENV PATH=/opt/conda/bin:$PATH

RUN conda install --yes openblas scikit-learn numpy scipy ipython jupyter matplotlib pandas

RUN conda install --yes -c conda-forge py4j

RUN conda install --yes seaborn

ENV \
  TENSORFLOW_HOME=/root/tensorflow

ENV \
 TENSORFLOW_VERSION=1.0.1


RUN \
  conda install --yes -c conda-forge jupyterhub==0.7.2 \
  && conda install --yes ipykernel==4.6.1 \
  && conda install --yes notebook==5.0.0 \
  && conda install --yes -c conda-forge jupyter_contrib_nbextensions==0.2.7 \
  && conda install --yes ipywidgets==6.0.0 \
  && conda install --yes -c anaconda-nb-extensions anaconda-nb-extensions==1.0.0 \
  && conda install --yes -c conda-forge findspark=1.0.0

RUN \
  pip install jupyterlab==0.19.0 \
  && pip install jupyterlab_widgets==0.6.15 \
  && pip install widgetslabextension==0.1.0

RUN \
  jupyter labextension install --sys-prefix --py jupyterlab_widgets \
  && jupyter labextension enable --sys-prefix --py jupyterlab_widgets \
  && jupyter serverextension enable --py jupyterlab --sys-prefix

RUN \
  jupyter nbextension install --py widgetsnbextension --sys-prefix \
  && jupyter nbextension enable --py widgetsnbextension --sys-prefix

RUN \
  pip install ipysankeywidget \
  && jupyter nbextension enable --py --sys-prefix ipysankeywidget

# Install non-secure dummyauthenticator for jupyterhub (dev purposes only)
RUN pip install jupyterhub-dummyauthenticator

RUN pip install jupyterhub-simplespawner

RUN pip install teradata

RUN mkdir -p /root/tensorboard

RUN mkdir -p /root/models

COPY config/ config/jupyterhub/

RUN pip install tensorflow==${TENSORFLOW_VERSION}

EXPOSE 6006 8754

COPY run run

RUN chmod +x /run

RUN mkdir /root/notebooks

CMD ["supervise", "."]


