FROM alpine:3.13

# Based on https://github.com/tatsushid/docker-alpine-py3-tensorflow-jupyter/blob/master/Dockerfile
# Changes:
# - Bumping versions of Bazel and Tensorflow
# - Add -Xmx to the Java params when building Bazel
# - Disable TF_GENERATE_BACKTRACE and TF_GENERATE_STACKTRACE

ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk
ENV LOCAL_RESOURCES 2048,.5,1.0
ENV BAZEL_VERSION 0.25.0
ENV TENSORFLOW_VERSION 1.15.5

RUN apk add --no-cache build-base python3 python3-tkinter py3-numpy py3-pip py3-numpy-f2py freetype libpng libjpeg-turbo imagemagick graphviz git
RUN apk add --no-cache --virtual=.build-deps \
        bash \
        cmake \
        curl \
        freetype-dev \
        g++ \
        gcc \
        libjpeg-turbo-dev \
        libpng-dev \
        linux-headers \
        make \
        musl-dev \
        openblas-dev \
        openjdk11 \
        patch \
        perl \
        alpine-sdk \
        python3-dev \
        openssl-dev \
        libffi-dev \
        py3-numpy-dev \
        rsync \
        sed \
        sudo \
        tmux \
        swig \
        zip \
        && apk add --virtual build-dependencies\
        && cd /tmp \
        && apk --no-cache add \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ \
        hdf5 \
        && apk --no-cache add --virtual .builddeps.edge \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ \
        hdf5-dev \
        && pip3 install six mock numpy h5py grpcio \
        && pip3 install --no-cache-dir wheel \
        && pip3 install keras_applications keras_preprocessing --no-deps \
        # && pip3 install h5py==2.8.0 \
        && $(cd /usr/bin && ln -s python3 python)

# Bazel download
RUN curl -SLO https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-dist.zip \
        && mkdir bazel-${BAZEL_VERSION} \
        && unzip -qd bazel-${BAZEL_VERSION} bazel-${BAZEL_VERSION}-dist.zip

# Bazel install
ENV EXTRA_BAZEL_ARGS="--host_javabase=@local_jdk//:jdk"
RUN cd bazel-${BAZEL_VERSION} \
        # && wget https://raw.githubusercontent.com/clearlinux-pkgs/tensorflow/master/Add-grpc-fix-for-gettid.patch \
        # && patch -p1 <Add-grpc-fix-for-gettid.patch \
        # && sed -i -e 's/-classpath/-J-Xmx8192m -J-Xms128m -classpath/g' scripts/bootstrap/compile.sh \
        && bash compile.sh \
        && sudo cp -p output/bazel /usr/bin/

# Download Tensorflow
RUN cd /tmp \
        && curl -SL https://github.com/tensorflow/tensorflow/archive/v${TENSORFLOW_VERSION}.tar.gz \
        | tar xzf -

# Build Tensorflow
RUN cd /tmp/tensorflow-${TENSORFLOW_VERSION} \
        && : musl-libc does not have "secure_getenv" function \
        && sed -i -e '/JEMALLOC_HAVE_SECURE_GETENV/d' third_party/jemalloc.BUILD \
        && sed -i -e '/define TF_GENERATE_BACKTRACE/d' tensorflow/core/platform/default/stacktrace.h \
        && sed -i -e '/define TF_GENERATE_STACKTRACE/d' tensorflow/core/platform/stacktrace_handler.cc \
        && PYTHON_BIN_PATH=/usr/bin/python \
        PYTHON_LIB_PATH=/usr/lib/python3.8/site-packages \
        CC_OPT_FLAGS="-march=native" \
        TF_NEED_JEMALLOC=1 \
        TF_NEED_GCP=0 \
        TF_NEED_HDFS=0 \
        TF_NEED_S3=0 \
        TF_ENABLE_XLA=0 \
        TF_NEED_GDR=0 \
        TF_NEED_VERBS=0 \
        TF_NEED_OPENCL=0 \
        TF_NEED_CUDA=0 \
        TF_NEED_MPI=0 \
        bash configure
RUN cd /tmp/tensorflow-${TENSORFLOW_VERSION} \
        && bazel build  --config=mkl -c opt --local_resources ${LOCAL_RESOURCES} //tensorflow/tools/pip_package:build_pip_package
ENV LOCAL_RESOURCES 7500,.5,1.0
RUN cd /tmp/tensorflow-${TENSORFLOW_VERSION} \
        && ./bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
RUN cp /tmp/tensorflow_pkg/tensorflow-${TENSORFLOW_VERSION}-cp36-cp36m-linux_x86_64.whl /root

# Make sure it's built properly
RUN pip3 install --no-cache-dir /root/tensorflow-${TENSORFLOW_VERSION}-cp36-cp36m-linux_x86_64.whl \
        && python3 -c 'import tensorflow'
