FROM redmancy/alpine-tensorflow:latest
RUN cd /tmp \
    && curl https://raw.githubusercontent.com/thy486/alpine-tensorflow/master/fix/env.cc -o env.cc \
    && cp -rf env.cc /tmp/tensorflow-${TENSORFLOW_VERSION}/tensorflow/core/platform/posix/env.cc \
    && cd /tmp/tensorflow-${TENSORFLOW_VERSION} \
    && apk add libexecinfo libexecinfo-dev \
    && sed -i -e '/undef HAVE_SYS_SYSCTL_H.*define HAVE_SYS_SYSCTL_H 1/d' third_party/hwloc/BUILD.bazel \
    # && sed -i 's/pthread_getname_np/pthread_setname_np/g' tensorflow/core/platform/posix/env.cc \
    && sed -i -e '/define TF_GENERATE_BACKTRACE/d' tensorflow/core/platform/default/stacktrace.h \
    && sed -i -e '/define TF_GENERATE_STACKTRACE/d' tensorflow/core/platform/default/stacktrace_handler.cc \
    && sed -i -e '/HAVE_BACKTRACE/d' third_party/llvm/llvm.bzl \
    && sed -i -e '/HAVE_MALLINFO/d' third_party/llvm/llvm.bzl \
    && PYTHON_BIN_PATH=/usr/bin/python \
        PYTHON_LIB_PATH=/usr/lib/python3.8/site-packages \
        CC_OPT_FLAGS="-march=native" \
        TF_NEED_OPENCL=0 \
        TF_ENABLE_XLA=0 \
        TF_NEED_OPENCL_SYCL=0 \
        TF_NEED_S3=0 \
        TF_NEED_ROCM=0 \
        TF_NEED_CUDA=0 \
        TF_DOWNLOAD_CLANG=0 \
        TF_NEED_MPI=0 \
        TF_SET_ANDROID_WORKSPACE=0 \
        bash configure \
        && cd /tmp/tensorflow-${TENSORFLOW_VERSION} \
        && bazel build \
        --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" \
        --verbose_failures \
        # --config=mkl \
        --copt=-UMALLINFO \
        --config=noaws \
        --config=nogcp \
        --config=nohdfs \
        # --config=nonccl \
        # --config=nokafka \
        # --config=noignite \
        -c opt \
        --local_resources ${LOCAL_RESOURCES} \
        //tensorflow/tools/pip_package:build_pip_package
