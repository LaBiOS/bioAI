FROM ubuntu:18.04
MAINTAINER Fabiano Menegidio <fabiano.menegidio@biology.bio.br>

##############################################################################
# Metadata
##############################################################################
LABEL base.image="ubuntu:18.04"
LABEL name.image="bioLearning - GPU Flavour"
LABEL version="1.0"
LABEL description="An all-in-one Docker image for Machine Learning and Deep Learning."
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
ADD packages/python-pkg.scif /root/.packages/
ADD packages/pythonML-pkg.scif /root/.packages/
ADD packages/tensorflow-gpu.scif /root/.packages/
ADD packages/keras.scif /root/.packages/
ADD packages/lasagne.scif /root/.packages/
ADD packages/darknet.scif /root/.packages/
ADD packages/pytorch-gpu.scif /root/.packages/
ADD packages/theano.scif /root/.packages/
ADD packages/opencv.scif /root/.packages/
ADD packages/chainer.scif /root/.packages/
ADD packages/mxnet.scif /root/.packages/
ADD packages/onnx.scif /root/.packages/
ADD packages/caffe-gpu.scif /root/.packages/
ADD packages/caffe2-gpu.scif /root/.packages/
ADD packages/mlflow.scif /root/.packages/
ADD packages/mlv-tools.scif /root/.packages/
ADD packages/scikit.scif /root/.packages/
ADD packages/biopython.scif /root/.packages/
ADD packages/dask.scif /root/.packages/
ADD packages/libsvm.scif /root/.packages/
ADD packages/graphviz.scif /root/.packages/
ADD packages/beautifulsoup.scif /root/.packages/
ADD packages/dm-sonnet-gpu.scif /root/.packages/
ADD packages/xgboost.scif /root/.packages/
ADD packages/git-annex.scif /root/.packages/
ADD packages/torch.scif /root/.packages/
ADD packages/cupy.scif /root/.packages/
ADD packages/pydata.scif /root/.packages/
ADD packages/cntk.scif /root/.packages/
ADD packages/blocks.scif /root/.packages/
ADD packages/neon.scif /root/.packages/
ADD packages/gensim.scif /root/.packages/
ADD packages/statsmodels.scif /root/.packages/
ADD packages/shogun.scif /root/.packages/
ADD packages/nupic.scif /root/.packages/
ADD packages/orange3.scif /root/.packages/
ADD packages/pymc.scif /root/.packages/
ADD packages/deap.scif /root/.packages/
ADD packages/annoy.scif /root/.packages/


##############################################################################
# ENVs
##############################################################################
ENV conda_env=py36
ENV DEBIAN_FRONTEND noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
ENV SHELL /bin/bash
ENV HOME /root
ENV CUDA_VERSION 10.1.168
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV CUDNN_VERSION 7.6.0
ENV PYTHON3_VERSION Miniconda3-latest
ENV PYTHON2_VERSION Miniconda2-latest
ENV JUPYTER_TYPE notebook
ENV JUPYTER_PORT 8888
ENV CONDA_DIR $HOME/.conda
ENV PATH $CONDA_DIR:$CONDA_DIR/bin:$PATH
ENV XDG_CACHE_HOME $HOME/.cache/

##############################################################################
# Install base dependencies
##############################################################################
RUN apt-get update \
    && LIBPNG="$(apt-cache depends libpng-dev | grep 'Depends: libpng' | awk '{print $2}')" \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-unauthenticated \
    --no-install-recommends bash git zip wget libssl1.0.0 apt-utils \
    ca-certificates locales mlocate debconf curl build-essential \
    curl vim bzip2 sudo automake cmake sed grep x11-utils xvfb openssl \
    libxtst6 libxcomposite1 $LIBPNG stunnel swig libjpeg-dev libpng-dev libreadline-dev \
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
    && conda update --all && conda clean -tipy \
    && \
##############################################################################
# Lasagne and dm-sonnet only work on Python <3.6 or Python <2.7.
# So we decided to use Python 3.6 as the container default.
# If you don't want to use these libraries, change your Python version to > 3.6.
##############################################################################
    conda create -n py36 python=3.6 -y

ENV CONDA_DEFAULT_ENV $conda_env

##############################################################################
# Install Scif
##############################################################################
RUN python -m pip --no-cache-dir install --upgrade scif \
    && conda clean -tipy \
    && \
##############################################################################
# Install packages through Scif
##############################################################################
##############################################################################
# Essentials Install
##############################################################################
    scif install $HOME/.packages/cuda.scif \
    && scif install $HOME/.packages/cdnn.scif \
    && scif install $HOME/.packages/python-pkg.scif \
    && scif install $HOME/.packages/biopython.scif \
    && scif install $HOME/.packages/jupyter.scif \
    && scif install $HOME/.packages/pythonML-pkg.scif \
    && scif install $HOME/.packages/dvc.scif \
    && scif install $HOME/.packages/mlflow.scif \
    && scif install $HOME/.packages/mlv-tools.scif \
    && scif install $HOME/.packages/graphviz.scif \
    && scif install $HOME/.packages/dask.scif \
    && scif install $HOME/.packages/git-annex.scif \
    && scif install $HOME/.packages/cupy.scif \
    && scif install $HOME/.packages/pydata.scif \
    && \
##############################################################################
# Nonessential Install
##############################################################################
    scif install $HOME/.packages/tensorflow-gpu.scif \
    && scif install $HOME/.packages/keras.scif \
    && scif install $HOME/.packages/scikit.scif \
    && scif install $HOME/.packages/beautifulsoup.scif \
    && scif install $HOME/.packages/pytorch-gpu.scif \
    && \
##############################################################################
# Nonessential
##############################################################################
    scif install $HOME/.packages/chainer.scif \
    && scif install $HOME/.packages/darknet.scif \
    && scif install $HOME/.packages/dm-sonnet-gpu.scif \
    && scif install $HOME/.packages/lasagne.scif \
    && scif install $HOME/.packages/libsvm.scif \
    && scif install $HOME/.packages/mxnet.scif \
    && scif install $HOME/.packages/onnx.scif \
    && scif install $HOME/.packages/opencv.scif \
    && scif install $HOME/.packages/theano.scif \
    && scif install $HOME/.packages/torch,scif \
    && scif install $HOME/.packages/xgboost.scif \
    && scif install $HOME/.packages/cntk.scif \
    && scif install $HOME/.packages/blocks.scif \
    && scif install $HOME/.packages/neon.scif \
    && scif install $HOME/.packages/gensim.scif \
    && scif install $HOME/.packages/statsmodels.scif \
    && scif install $HOME/.packages/shogun.scif \
    && scif install $HOME/.packages/nupic.scif \
    && scif install $HOME/.packages/orange3.scif \
    && scif install $HOME/.packages/pymc.scif \
    && scif install $HOME/.packages/deap.scif \
    && scif install $HOME/.packages/annoy.scif

EXPOSE 6000
EXPOSE 8888
VOLUME ["$HOME/workdir/data"]
CMD ["/usr/local/bin/start-notebook.sh"]
