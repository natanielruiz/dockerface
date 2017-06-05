FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu16.04
LABEL maintainer caffe-maint@googlegroups.com

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        git \
        wget \
        libatlas-base-dev \
        libboost-all-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        libleveldb-dev \
        liblmdb-dev \
        libopencv-dev \
        libprotobuf-dev \
        libsnappy-dev \
        protobuf-compiler \
        python-dev \
        python-numpy \
        python-pip \
        python-setuptools \
        python-scipy && \
    rm -rf /var/lib/apt/lists/*

ENV FAST_RCNN_ROOT=/opt
WORKDIR $FAST_RCNN_ROOT

RUN git clone https://github.com/opencv/opencv.git && \
	cd opencv && \
	mkdir build && \
	cd build && \
	cmake .. -DWITH_FFMPEG=ON && \
	make -j20 && make install && \
	cd ../..

RUN pip install --upgrade pip && \
	pip install cython && \
	pip install easydict

RUN apt-get update && \
	apt-get -y install python-tk

RUN git clone https://github.com/natanielruiz/py-faster-rcnn-dockerface py-faster-rcnn && \
	cd py-faster-rcnn && \
	mkdir output && cd output && mkdir faster_rcnn_end2end && cd faster_rcnn_end2end && \
	mkdir wider && cd wider && \
	wget "https://www.dropbox.com/s/dhtawqycd32ca9v/vgg16_dockerface_iter_80000.caffemodel" && \
	cd ../../.. && \
	cd lib && \
	make && \
	cd .. && \
	rm -r caffe-fast-rcnn && \
	git clone https://github.com/owphoo/caffe_fast_rcnn.git caffe-fast-rcnn && \
	cd caffe-fast-rcnn && \
	cd python && for req in $(cat requirements.txt) pydot; do pip install $req; done && cd .. && \
	mkdir build && cd build && \
	cmake -DUSE_CUDNN=1 .. && \
	make -j"$(nproc)" && \
	make pycaffe

ENV PYCAFFE_ROOT $CAFFE_ROOT/python
ENV PYTHONPATH $PYCAFFE_ROOT:$PYTHONPATH
ENV PATH $CAFFE_ROOT/build/tools:$PYCAFFE_ROOT:$PATH
RUN echo "$CAFFE_ROOT/build/lib" >> /etc/ld.so.conf.d/caffe.conf && ldconfig

WORKDIR /opt/py-faster-rcnn
