FROM python:3.10.7-slim-buster AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

WORKDIR /root

RUN apt-get update && \
    apt-get install -y \
    build-essential \
    cmake \
    git \
    curl \
    autoconf \
    automake \
    git-core \
    libass-dev \
    libfreetype6-dev \
    libgnutls28-dev \
    libmp3lame-dev \
    libsdl2-dev \
    libtool \
    libva-dev \
    libvdpau-dev \
    libvorbis-dev \
    libxcb1-dev \
    libxcb-shm0-dev \
    libxcb-xfixes0-dev \
    meson \
    ninja-build \
    pkg-config \
    texinfo \
    wget \
    nasm \
    yasm \
    zlib1g-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncurses5-dev \
    libffi-dev \
    liblzma-dev \
    tk-dev \
    libnuma-dev \
    libssl-dev \
    libbz2-dev \
    gcc \
    g++ \
    make \
    pkg-config \
    libc6-dev \
    libpng-dev \
    gcc-8-base \
    libgcc1 \
    libstdc++6 \
    libx264-dev \
    libx265-dev \
    libopus-dev \
    libvpx-dev

# # Install build tools
# RUN yum update && \
#   yum upgrade -y && \
#   yum install -y \
#     wget \
#     unzip \
#     cmake \
#     git \
#     autoconf \
#     automake \
#     git-core  \
#     cmake  \
#     gcc  \
#     gcc-c++  \
#     libtool  \
#     make  \
#     pkgconfig  \
#     glibc-static \
#     numactl-devel \
#     openssl \
#     openssl-devel \
#     zlib \
#     zlib-devel \
#     bzip2 \
#     bzip2-devel \
#     readline \
#     readline-devel \
#     sqlite \
#     sqlite-devel \
#     ncurses \
#     ncurses-devel \
#     libffi \
#     libffi-devel \
#     xz \
#     xz-devel \
#     tk \
#     tk-devel \
#     libuuid \
#     libuuid-devel \
#     libyaml \
#     libyaml-devel \
#     expat \
#     expat-devel \
#     libtirpc \
#     libtirpc-devel \
#     libxcrypt \
#     libxcrypt-devel \
#     freetype \
#     freetype-devel \
#     gnutls \
#     gnutls-devel \
#     SDL2 \
#     SDL2-devel \
#     libva \
#     libva-devel \
#     libvdpau \
#     libvdpau-devel \
#     libvorbis \
#     libvorbis-devel \
#     libxcb \
#     libxcb-devel \
#     libass \
#     libass-devel \
#     ninja-build \
#     texinfo && \
#     yum groupinstall 'Development Tools' -y

# # Install bzip2 from source if static package not available
# RUN if ! rpm -q bzip2-static; then \
#     cd /tmp && \
#     wget https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz && \
#     tar -xzf bzip2-1.0.8.tar.gz && \
#     cd bzip2-1.0.8 && \
#     make -f Makefile-libbz2_so && \
#     make install PREFIX=/usr/local && \
#     cp libbz2.so.1.0.8 /usr/local/lib/ && \
#     ln -sf /usr/local/lib/libbz2.so.1.0.8 /usr/local/lib/libbz2.so.1 && \
#     ln -sf /usr/local/lib/libbz2.so.1 /usr/local/lib/libbz2.so && \
#     rm -rf /tmp/bzip2-1.0.8*; \
#     fi

# # Install newer cmake
# RUN cd /tmp && \
#     wget https://github.com/Kitware/CMake/releases/download/v3.31.8/cmake-3.31.8.tar.gz && \
#     tar -xzf cmake-3.31.8.tar.gz && \
#     cd cmake-3.31.8 && \
#     ./bootstrap --prefix=/usr/local && \
#     make -j$(nproc) && \
#     make install && \
#     rm -rf /tmp/cmake-3.31.8*

WORKDIR /root

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
    cmake \
    -D CMAKE_BUILD_TYPE=RELEASE \
    -D OPENCV_GENERATE_PKGCONFIG=YES \
    -D OPENCV_ENABLE_NONFREE=OFF \
    -D BUILD_LIST=core,imgproc \
    -D BUILD_TESTS=OFF \
    -D BUILD_PERF_TESTS=OFF \
    -D BUILD_EXAMPLES=OFF \
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

