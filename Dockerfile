FROM nvidia/cuda:8.0-devel
LABEL maintainer "Fabiano Menegidio <fabiano.menegidio@biology.bio.br>"

# Metadata
LABEL base.image="biodeeplearn:latest"
LABEL version="1"
LABEL software="Chainer"
LABEL software.version=""
LABEL description=""
LABEL website=""
LABEL documentation=""

ENV DEBIAN_FRONTEND noninteractive

RUN rm -rf /var/lib/apt/lists/* \
           /etc/apt/sources.list.d/cuda.list \
           /etc/apt/sources.list.d/nvidia-ml.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
           apt-utils \
           build-essential \
           ca-certificates \
           wget \
           git \
           vim \
           make \
           libssl-dev \
           libsqlite3-dev \
           zlib1g-dev \
           libbz2-dev \
           libreadline-dev \
           libatlas-base-dev \
           libboost-all-dev \
           libgflags-dev \
           libgoogle-glog-dev \
           libhdf5-serial-dev \
           libleveldb-dev \
           liblmdb-dev \
           libprotobuf-dev \
           libsnappy-dev \
           protobuf-compiler \
           graphviz \
           openmpi-bin \
           libjasper-dev \
    && \           
    
# =================================
# Install CMake
# =================================
    git clone --depth 10 https://github.com/Kitware/CMake ~/cmake \
    && cd ~/cmake \
    && ./bootstrap --prefix=/usr/local \
    && make -j"$(nproc)" install \
    && \

# =================================
# Install python3 and dependences
# =================================
    apt-get install -y --no-install-recommends \
           python3-pip \
           python3-dev \
    && ln -s /usr/bin/python3 /usr/local/bin/python \
    && pip3 --no-cache-dir install --upgrade \
           pip \
           setuptools \
           numpy \
           scipy \
           pandas \
           scikit-learn \
           matplotlib \
           Cython \
    && \
    
    ls /usr/local/lib/ && \

# =================================
# Install Caffe
# =================================
    git clone --depth 10 https://github.com/NVIDIA/nccl \
    && cd nccl; make -j"$(nproc)" install; cd ..; rm -rf nccl \
    && git clone --depth 10 https://github.com/BVLC/caffe ~/caffe \
    && mkdir ~/caffe/build && cd ~/caffe/build \
    && cmake -D CMAKE_BUILD_TYPE=RELEASE \
           -D CMAKE_INSTALL_PREFIX=/usr/local \
           -D USE_CUDNN=1 \
           -D USE_NCCL=1 \
           -D python_version=3 \
           -D CUDA_NVCC_FLAGS=--Wno-deprecated-gpu-targets \
           -Wno-dev .. \
    && make -j"$(nproc)" install \
    && sed -i 's/,<2//g' ~/caffe/python/requirements.txt \
    && pip3 --no-cache-dir install --upgrade \
           -r ~/caffe/python/requirements.txt \
    && mv /usr/local/python/caffe /usr/local/lib/python3.5/dist-packages/ \
    && rm -rf /usr/local/python \

# =================================
# Install Chainer
# =================================
    pip3 --no-cache-dir install --upgrade \
           cupy \
           chainer \
    && \

# =================================
# Install Keras
# =================================
    pip3 --no-cache-dir install --upgrade \
           h5py \
           keras \
    && \
    
# =================================
# Install Lasagne
# =================================
    git clone --depth 10 https://github.com/Lasagne/Lasagne ~/lasagne \
    && cd ~/lasagne \
    && pip3 --no-cache-dir install --upgrade . \
    && \    

# =================================
# Install Microsoft Cognitive Toolkit (CNTK)
# =================================
    pip3 --no-cache-dir install --upgrade \
           https://cntk.ai/PythonWheel/GPU/cntk-2.2-cp36-cp36m-linux_x86_64.whl \
    && \

# =================================
# Intall MXNet
# =================================
    pip3 --no-cache-dir install --upgrade \
           mxnet-cu80 \
           graphviz \
    && \

# =================================
# Install OpenCV
# =================================   
    git clone --depth 10 https://github.com/opencv/opencv ~/opencv \
    && mkdir -p ~/opencv/build && cd ~/opencv/build \
    && cmake -D CMAKE_BUILD_TYPE=RELEASE \
           -D CMAKE_INSTALL_PREFIX=/usr/local \
           -D WITH_IPP=OFF \
           -D WITH_CUDA=OFF \
           -D WITH_OPENCL=OFF \
           -D BUILD_TESTS=OFF \
           -D BUILD_PERF_TESTS=OFF .. \
    && make -j"$(nproc)" install \
    && \

# =================================
# Install pyTorch
# =================================
    pip3 --no-cache-dir install --upgrade \
           http://download.pytorch.org/whl/cu80/torch-0.2.0.post3-cp36-cp36m-manylinux1_x86_64.whl \
           torchvision \
    && \

# =================================
# Install Sonnet
# =================================
    pip3 --no-cache-dir install --upgrade \
           dm-sonnet \
    && \

# =================================
# Install Tensorflow
# =================================
    pip3 --no-cache-dir install --upgrade \
           tensorflow_gpu \
    && \
    
# =================================
# Install Theano
# =================================
    git clone --depth 10 https://github.com/Theano/Theano ~/theano \
    && cd ~/theano \
    && pip3 --no-cache-dir install . \
    && git clone --depth 10 https://github.com/Theano/libgpuarray ~/gpuarray \
    && mkdir -p ~/gpuarray/build && cd ~/gpuarray/build \
    && cmake -D CMAKE_BUILD_TYPE=RELEASE \
             -D CMAKE_INSTALL_PREFIX=/usr/local .. \
    && make -j"$(nproc)" install \
    && cd ~/gpuarray \
    && python setup.py build \
    && python setup.py install \
    && printf '[global]\nfloatX = float32\ndevice = cuda0\n\n[dnn]\ninclude_path = /usr/local/cuda/targets/x86_64-linux/include\n' \
    > ~/.theanorc
