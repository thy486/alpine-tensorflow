FROM alpine:3.12

# Based on https://github.com/tatsushid/docker-alpine-py3-tensorflow-jupyter/blob/master/Dockerfile
# Changes:
# - Bumping versions of Bazel and Tensorflow
# - Add -Xmx to the Java params when building Bazel
# - Disable TF_GENERATE_BACKTRACE and TF_GENERATE_STACKTRACE

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    LANG=zh_CN.UTF-8 \
    SHELL=/bin/bash PS1="\u@\h:\w \$ " \
    JAVA_HOME=/usr/lib/jvm/default-jvm \
    BAZEL_VERSION=0.25.0 \
    TENSORFLOW_VERSION=1.15.5 \
    LOCAL_RESOURCES=2048,.5,1.0 \
    EXTRA_BAZEL_ARGS=--host_javabase=@local_jdk//:jdk
WORKDIR /root

RUN apk add --no-cache python3 python3-tkinter py3-numpy py3-numpy-f2py libcurl freetype libpng libjpeg-turbo libstdc++ imagemagick graphviz git
RUN apk add --no-cache --virtual=.build-deps \
        bash \
        coreutils \
        protobuf \
        cmake \
        curl \
        freetype-dev \
        g++ \
        libjpeg-turbo-dev \
        libpng-dev \
        linux-headers \
        make \
        musl-dev \
        openblas-dev \
        openjdk8 \
        patch \
        perl \
        python3-dev \
        py3-numpy-dev \
        py3-pip \
        rsync \
        sed \
        swig \
        sudo \
        zip \
        libexecinfo-dev \
        && cd /tmp \
        && curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
        && sudo python3 get-pip.py \
        && apk --no-cache add \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ \
        hdf5 \
        && apk --no-cache add --virtual .builddeps.edge \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ \
        hdf5-dev \
        && rm -rf /var/cache/apk/* \
        && pip3 install numpy==1.18.0 h5py==2.9.0 \
        && pip3 install -U --user keras_preprocessing keras_applications --no-deps \
        && pip3 install --no-cache-dir setuptools wheel \
        # && pip3 install keras_preprocessing --no-deps \
        # && pip3 install h5py==2.8.0 \
        && $(cd /usr/bin && ln -s python3 python)

# Bazel download and install
RUN curl -SLO https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-dist.zip \
        && mkdir bazel-${BAZEL_VERSION} \
        && unzip -qd bazel-${BAZEL_VERSION} bazel-${BAZEL_VERSION}-dist.zip \
        && cd bazel-${BAZEL_VERSION} \
        && sed -i -e 's/-classpath/-J-Xmx8192m -J-Xms128m -classpath/g' scripts/bootstrap/compile.sh \
        && bash compile.sh \
        && cp -p output/bazel /usr/local/bin/ \
        && cp -p output/bazel /usr/bin/

# Download Tensorflow
RUN cd /tmp \
        && curl -SL https://github.com/tensorflow/tensorflow/archive/v${TENSORFLOW_VERSION}.tar.gz \
        | tar xzf -

# # Download and Build Tensorflow
# RUN cd /tmp \
#         && curl -SL https://github.com/tensorflow/tensorflow/archive/v${TENSORFLOW_VERSION}.tar.gz \
#         | tar xzf - \
#         && cd /tmp/tensorflow-${TENSORFLOW_VERSION} \
#         && : musl-libc does not have "secure_getenv" function \
#         && bazel clean \
#         && sed -i -e '/undef HAVE_SYS_SYSCTL_H.*define HAVE_SYS_SYSCTL_H 1/d' third_party/hwloc/BUILD.bazel \
#         # && sed -i -e '/#include <execinfo.h>/d' tensorflow/core/platform/default/stacktrace.h \
#         # && sed -i -e '/JEMALLOC_HAVE_SECURE_GETENV/d' third_party/jemalloc.BUILD \
#         # && sed -i -e '/define TF_GENERATE_BACKTRACE/d' tensorflow/core/platform/default/stacktrace.h \
#         # && sed -i -e '/define TF_GENERATE_STACKTRACE/d' tensorflow/core/platform/default/stacktrace_handler.cc \
#         && PYTHON_BIN_PATH=/usr/bin/python \
#         PYTHON_LIB_PATH=/usr/lib/python3.8/site-packages \
#         CC_OPT_FLAGS="-march=native" \
#         # TF_NEED_OPENCL=0 \
#         TF_ENABLE_XLA=0 \
#         TF_NEED_OPENCL_SYCL=0 \
#         TF_NEED_ROCM=0 \
#         TF_NEED_CUDA=0 \
#         TF_DOWNLOAD_CLANG=0 \
#         TF_NEED_MPI=0 \
#         TF_SET_ANDROID_WORKSPACE=0 \
#         bash configure \
#         && cd /tmp/tensorflow-${TENSORFLOW_VERSION} \
#         && bazel build \
#         --verbose_failures \
#         # --config=mkl \
#         --config=noaws \
#         --config=nogcp \
#         --config=nohdfs \
#         -c opt \
#         --local_resources ${LOCAL_RESOURCES} \
#         //tensorflow/tools/pip_package:build_pip_package

# RUN cd /tmp/tensorflow-${TENSORFLOW_VERSION} \
#         && ./bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
# # RUN cp /tmp/tensorflow_pkg/tensorflow-${TENSORFLOW_VERSION}-cp38-cp38m-linux_x86_64.whl /root

# # Make sure it's built properly
# # RUN pip3 install --no-cache-dir /root/tensorflow-${TENSORFLOW_VERSION}-cp38-cp38m-linux_x86_64.whl \
# #         && python3 -c 'import tensorflow'
