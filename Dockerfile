FROM ubuntu:18.04
MAINTAINER Fabiano Menegidio <fabiano.menegidio@biology.bio.br>

##############################################################################
# Metadata
##############################################################################
LABEL base.image="bioAI:gpu"
LABEL version="1"
LABEL description=""
LABEL website=""
LABEL documentation=""

##############################################################################
# ADD config files
##############################################################################
ADD .config/start.sh /start.sh
ADD .config/start-notebook.sh /usr/local/bin/
ADD .config/bashrc/.bashrc $HOME/.bashrc
ADD .config/bashrc/.bash_profile $HOME/.bash_profile

##############################################################################
# ADD packages files
##############################################################################
ADD packages/dvc.scif /root/.packages/
ADD packages/cuda.scif /root/.packages/
ADD packages/cdnn.scif /root/.packages/
ADD packages/jupyter.scif /root/.packages/
ADD packages/python.scif /root/.packages/
ADD packages/pythonML.scif /root/.packages/
ADD packages/tensorflow-gpu.scif /root/.packages/
ADD packages/keras-gpu.scif /root/.packages/
ADD packages/lasagne.scif /root/.packages/
ADD packages/darknet.scif /root/.packages/
ADD packages/pytorch-gpu.scif /root/.packages/
ADD packages/theano.scif /root/.packages/
ADD packages/opencv.scif /root/.packages/
ADD packages/chainer.scif /root/.packages/
ADD packages/mxnet.scif /root/.packages/
ADD packages/onnx.scif /root/.packages/
ADD packages/caffe.scif /root/.packages/
ADD packages/torch.scif /root/.packages/
ADD packages/mlflow.scif /root/.packages/
ADD packages/mlvtools.scif /root/.packages/
ADD packages/scikit.scif /root/.packages/
ADD packages/scikitbio.scif /root/.packages/
ADD packages/biopython.scif /root/.packages/
ADD packages/dask.scif /root/.packages/
ADD packages/libsvm.scif /root/.packages/
ADD packages/graphviz.scif /root/.packages/
ADD packages/beautifulsoup.scif /root/.packages/
ADD packages/dm-sonnet-gpu.scif /root/.packages/
ADD packages/xgboost.scif /root/.packages/

##############################################################################
# ENVs
##############################################################################
ENV DEBIAN_FRONTEND noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
ENV SHELL /bin/bash
ENV HOME /root
ENV CUDA_VERSION 10.0.130
ENV CUDA_PKG_VERSION 10-0=$CUDA_VERSION-1
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=10.0 brand=tesla,driver>=384,driver<385"
ENV CUDA_PATH /usr/local/cuda/bin
ENV CUDNN_VERSION 7.3.1.20
ENV PYTHON3_VERSION Miniconda3-latest
ENV PYTHON2_VERSION Miniconda2-latest
ENV JUPYTER_TYPE notebook
ENV JUPYTER_PORT 8888
ENV CONDA_DIR $HOME/.conda
ENV PATH $CONDA_DIR:$CONDA_DIR/bin:$PATH


##############################################################################
# Install base dependencies
##############################################################################
RUN apt-get update \
    && LIBPNG="$(apt-cache depends libpng-dev | grep 'Depends: libpng' | awk '{print $2}')" \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-unauthenticated \
    --no-install-recommends bash git zip wget libssl1.0.0 apt-utils \
    ca-certificates locales mlocate debconf curl build-essential \
    curl vim bzip2 sudo automake cmake sed grep x11-utils xvfb openssl \
    libxtst6 libxcomposite1 $LIBPNG stunnel swig \
    && wget https://dvc.org/deb/dvc.list -O /etc/apt/sources.list.d/dvc.list \
    && apt-get update \
    && apt-get clean && apt-get autoclean && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/ \
    && echo "LC_ALL=en_US.UTF-8" >> /etc/environment \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && echo "LANG=en_US.UTF-8" > /etc/locale.conf \
    && locale-gen en_US.UTF-8 \
    && dpkg-reconfigure locales \
    && mkdir -p /.config \
    && mkdir -p $HOME/workdir/data \
    && mkdir -p $HOME/workdir/notebooks \
    && chmod +x /start.sh \
    && chmod +x /usr/local/bin/start-notebook.sh \
    && \
##############################################################################
# Install Miniconda dependencies
##############################################################################
    wget --quiet https://repo.anaconda.com/miniconda/${PYTHON3_VERSION}-Linux-x86_64.sh \
    && /bin/bash ${PYTHON3_VERSION}-Linux-x86_64.sh -b -p ${CONDA_DIR} \
    && rm ${PYTHON3_VERSION}-Linux-x86_64.sh \
    && /bin/bash -c "exec $SHELL -l" \
    && /bin/bash -c "source $HOME/.bashrc" \
    && conda config --add channels conda-forge \
    && conda config --add channels bioconda \
    && conda config --add channels anaconda \
    && \
##############################################################################
# Lasagne and dm-sonnet only work on Python <3.6 or Python <2.7.
# So we decided to use Python 3.6 as the container default.
# If you don't want to use these libraries, change your Python version to > 3.6.
##############################################################################
    conda create -n py36 python=3.6 -y
    && conda activate py36 \
    && \
##############################################################################
# Install Scif
##############################################################################
    pip --no-cache-dir install scif \
    && conda update --all && conda clean -tipsy
    
##############################################################################
# Install packages through Scif
##############################################################################
RUN scif install $HOME/.packages/dvc.scif \
    && \     
    scif install $HOME/.packages/cuda.scif \
    && scif install $HOME/.packages/cdnn.scif \
    && scif install $HOME/.packages/python.scif \
    && scif install $HOME/.packages/jupyter.scif \
    && scif install $HOME/.packages/pythonML.scif \
    && scif install $HOME/.packages/tensorflow-gpu.scif \
    && scif install $HOME/.packages/keras-gpu.scif \
    && scif install $HOME/.packages/mlflow.scif \
    && scif install $HOME/.packages/mlvtools.scif \
    && scif install $HOME/.packages/scikitbio.scif \
    && scif install $HOME/.packages/scikit.scif \
    && scif install $HOME/.packages/biopython.scif \
    && scif install $HOME/.packages/graphviz.scif \
    && scif install $HOME/.packages/beautifulsoup.scif \
    && scif install $HOME/.packages/darknet.scif \
    && scif install $HOME/.packages/pytorch-gpu.scif \
    && scif install $HOME/.packages/theano.scif \
    && scif install $HOME/.packages/opencv.scif \
    && scif install $HOME/.packages/chainer.scif \
    && scif install $HOME/.packages/mxnet.scif \
    && scif install $HOME/.packages/onnx.scif \
    && scif install $HOME/.packages/caffe.scif \
    && scif install $HOME/.packages/torch.scif \
    && scif install $HOME/.packages/dask.scif \
    && scif install $HOME/.packages/libsvm.scif \
    && scif install $HOME/.packages/lasagne.scif \
    && scif install $HOME/.packages/dm-sonnet-gpu.scif \
    && scif install $HOME/.packages/xgboost.scif \
    && /bin/bash -c "exec $SHELL -l"

EXPOSE 6000
EXPOSE 8888
VOLUME ["$HOME/workdir/data"]
CMD ["/usr/local/bin/start-notebook.sh"]
