FROM redmancy/alpine-tensorflow:latest
RUN cd /tmp/tensorflow-${TENSORFLOW_VERSION} \
    &&PYTHON_BIN_PATH=/usr/bin/python3 \
        PYTHON_LIB_PATH=/usr/lib/python3.8/site-packages \
        CC_OPT_FLAGS="-march=native" \
        # TF_NEED_OPENCL=0 \
        TF_ENABLE_XLA=0 \
        TF_NEED_OPENCL_SYCL=0 \
        TF_NEED_ROCM=0 \
        TF_NEED_CUDA=0 \
        TF_DOWNLOAD_CLANG=0 \
        TF_NEED_MPI=0 \
        TF_SET_ANDROID_WORKSPACE=0 \
        bash configure \
        && cd /tmp/tensorflow-${TENSORFLOW_VERSION} \
        && bazel build \
        --verbose_failures \
        # --config=mkl \
        --config=noaws \
        --config=nogcp \
        --config=nohdfs \
        --config=nohdfs \
        --config=nonccl \
        --config=nokafka \
        --config=noignite \
        -c opt \
        --local_resources ${LOCAL_RESOURCES} \
        //tensorflow/tools/pip_package:build_pip_package
