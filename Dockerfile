ARG ARCH=x86_64

FROM quay.io/pypa/manylinux_2_28_${ARCH} AS builder

WORKDIR /root

RUN dnf install -y dnf-plugins-core epel-release && \
    dnf install -y https://download1.rpmfusion.org/free/el/rpmfusion-free-release-8.noarch.rpm && \
    dnf install -y \
    autoconf \
    automake \
    cmake \
    freetype-devel \
    gnutls-devel \
    lame-devel \
    SDL2-devel \
    libtool \
    libva-devel \
    libvdpau-devel \
    libvorbis-devel \
    libxcb-devel \
    meson \
    ninja-build \
    texinfo \
    nasm \
    yasm \
    readline-devel \
    sqlite-devel \
    ncurses-devel \
    libffi-devel \
    xz-devel \
    tk-devel \
    numactl-devel \
    openssl-devel \
    bzip2-devel \
    libpng-devel \
    x264-devel \
    x265-devel \
    opus-devel \
    libvpx-devel && \
    dnf update -y cmake

# RUN apt-get update && \
#     apt-get install -y \
#     build-essential \
#     cmake \
#     git \
#     curl \
#     autoconf \
#     automake \
#     git-core \
#     libass-dev \
#     libfreetype6-dev \
#     libgnutls28-dev \
#     libmp3lame-dev \
#     libsdl2-dev \
#     libtool \
#     libva-dev \
#     libvdpau-dev \
#     libvorbis-dev \
#     libxcb1-dev \
#     libxcb-shm0-dev \
#     libxcb-xfixes0-dev \
#     meson \
#     ninja-build \
#     pkg-config \
#     texinfo \
#     wget \
#     nasm \
#     yasm \
#     zlib1g-dev \
#     libreadline-dev \
#     libsqlite3-dev \
#     libncurses5-dev \
#     libffi-dev \
#     liblzma-dev \
#     tk-dev \
#     libnuma-dev \
#     libssl-dev \
#     libbz2-dev \
#     gcc \
#     g++ \
#     make \
#     pkg-config \
#     libc6-dev \
#     libpng-dev \
#     gcc-8-base \
#     libgcc1 \
#     libstdc++6 \
#     libx264-dev \
#     libx265-dev \
#     libopus-dev \
#     libvpx-dev

WORKDIR /root

## Install modern CMake from source
RUN cd /root && \
    curl -LO https://github.com/Kitware/CMake/releases/download/v3.27.7/cmake-3.27.7.tar.gz && \
    tar xzf cmake-3.27.7.tar.gz && \
    cd cmake-3.27.7 && \
    ./bootstrap --prefix=/usr/local && \
    make -j$(nproc) && \
    make install && \
    cd .. && \
    rm -rf cmake-3.27.7 cmake-3.27.7.tar.gz

## Install FFMPEG
WORKDIR ffmpeg_sources

COPY ./ffmpeg_patch /root/ffmpeg_sources/ffmpeg_patch
ENV FFMPEG_INSTALL_DIR=/root/ffmpeg_sources/FFmpeg
ENV FFMPEG_PATCH_DIR=/root/ffmpeg_sources/ffmpeg_patch

RUN cd ~/ffmpeg_sources && \
    git clone https://github.com/FFmpeg/FFmpeg.git --branch n4.1.3 --depth 1 && \
    cd FFmpeg && \
    /root/ffmpeg_sources/ffmpeg_patch/patch.sh && \
    ./configure \
    --pkg-config-flags="--static" \
    --extra-cflags="-I/usr/local/include" \
    --extra-ldflags="-L/usr/local/lib" \
    --extra-libs="-lpthread -lm" \
    --enable-static \
    --disable-shared \
    --enable-gpl \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopus \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libx264 \
    --enable-libx265 \
    --enable-nonfree \
    --enable-pic || cat ffbuild/config.log && \
    make -j$(nproc) && \
    make install && \
    rm -rf ~/ffmpeg_sources/FFmpeg

# Install OpenCV
RUN git clone https://github.com/opencv/opencv.git --branch 4.5.5 --depth 1 && \
    mkdir -p opencv/build && \
    cd opencv/build && \
    PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/lib64/pkgconfig \
    /usr/local/bin/cmake \
    -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_MINIMUM_REQUIRED_VERSION=3.5 \
    -D OPENCV_GENERATE_PKGCONFIG=ON \
    -D OPENCV_ENABLE_NONFREE=OFF \
    -D BUILD_LIST=core,imgproc \
    -D BUILD_TESTS=OFF \
    -D BUILD_PERF_TESTS=OFF \
    -D BUILD_EXAMPLES=OFF \
    -D BUILD_SHARED_LIBS=OFF \
    -D CMAKE_INSTALL_LIBDIR=lib \
    -D OPENCV_FORCE_3RDPARTY_BUILD=ON \
    -D BUILD_opencv_apps=OFF \
    -D BUILD_ZLIB=ON \
    -D BUILD_TIFF=OFF \
    -D BUILD_JASPER=OFF \
    -D BUILD_JPEG=ON \
    -D BUILD_PNG=ON \
    -D BUILD_WEBP=OFF \
    -D BUILD_opencv_java=OFF \
    -D BUILD_opencv_python=OFF \
    -D BUILD_opencv_python2=OFF \
    -D BUILD_opencv_python3=OFF \
    -D WITH_FFMPEG=OFF \
    -D WITH_GTK=OFF \
    -D WITH_QT=OFF \
    -D WITH_OPENGL=OFF \
    -D WITH_OPENCL=OFF \
    -D WITH_CUDA=OFF \
    -D WITH_1394=OFF \
    -D WITH_GSTREAMER=OFF \
    -D WITH_V4L=OFF \
    -D WITH_LIBV4L=OFF \
    -D WITH_VA=OFF \
    -D WITH_VA_INTEL=OFF \
    -D WITH_GDAL=OFF \
    -D WITH_XINE=OFF \
    -D WITH_OPENEXR=OFF \
    -D WITH_IPP=OFF \
    -D WITH_TBB=OFF \
    -D WITH_EIGEN=OFF \
    -D WITH_CUBLAS=OFF \
    -D WITH_CUFFT=OFF \
    -D WITH_NVCUVID=OFF \
    -D WITH_OPENCL_SVM=OFF \
    -D WITH_OPENCLAMDFFT=OFF \
    -D WITH_OPENCLAMDBLAS=OFF \
    -D WITH_DIRECTX=OFF \
    -D WITH_OPENCL_D3D11_NV=OFF \
    -D WITH_LAPACK=OFF \
    -D WITH_IPP_A=OFF \
    -D WITH_OPENCLAMDBLAS=OFF \
    -D WITH_OPENCLAMDFFT=OFF \
    -D WITH_OPENCL_SVM=OFF \
    -D WITH_OPENCL_D3D11_NV=OFF \
    -D WITH_DIRECTX=OFF \
    -D WITH_CUBLAS=OFF \
    -D WITH_CUFFT=OFF \
    -D WITH_NVCUVID=OFF \
    -D WITH_EIGEN=OFF \
    -D WITH_TBB=OFF \
    -D WITH_IPP=OFF \
    -D WITH_OPENEXR=OFF \
    -D WITH_XINE=OFF \
    -D WITH_GDAL=OFF \
    -D WITH_VA_INTEL=OFF \
    -D WITH_VA=OFF \
    -D WITH_LIBV4L=OFF \
    -D WITH_V4L=OFF \
    -D WITH_GSTREAMER=OFF \
    -D WITH_1394=OFF \
    -D WITH_CUDA=OFF \
    -D WITH_OPENCL=OFF \
    -D WITH_OPENGL=OFF \
    -D WITH_QT=OFF \
    -D WITH_GTK=OFF \
    -D WITH_FFMPEG=OFF \
    -D BUILD_EXAMPLES=OFF \
    -D BUILD_PERF_TESTS=OFF \
    -D BUILD_TESTS=OFF \
    .. && \
    make -j$(($(nproc) / 2)) && \
    make install && \
    cp ./unix-install/opencv4.pc /usr/local/lib/pkgconfig/ && \
    rm -rf ~/opencv

