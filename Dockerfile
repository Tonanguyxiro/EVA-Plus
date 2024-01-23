#! Start build with command:
#! docker build -t eva:latest .


# ubunutu is the base image
FROM ubuntu:22.04

LABEL maintainer="Tong"

#* Switch source
RUN echo "************************ Switch source ************************"
RUN cp -a /etc/apt/sources.list /etc/apt/sources.list.bak
COPY ./sources.list /etc/apt/sources.list
# RUN sed -i "s@http://.*archive.ubuntu.com@https://mirrors.sustech.edu.cn@g" /etc/apt/sources.list
# RUN sed -i "s@http://.*security.ubuntu.com@https://mirrors.sustech.edu.cn@g" /etc/apt/sources.list 


#* General update
RUN echo "************************ Set up env ************************"
# RUN apt-get update
#-y is for accepting yes when the system asked us for installing the package
RUN apt-get update && apt-get install -y ca-certificates && \
    apt-get update && apt-get install build-essential -y && \
    apt-get install -y cmake git openssh-server gdb pkg-config valgrind systemd-coredump && \
    # apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa
    # apt-get update && \
RUN apt-get install -y python3.10 python3.10-dev python3.10-distutils python3-pip
RUN apt-get install -y autoconf automake libtool curl make g++ unzip
RUN apt-get install -y libomp-dev
RUN apt-get install -y fish
 
RUN apt-get install -y clang && \
    update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 && \
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++ 100

#* Install protobuf (v3.20.3)
RUN echo "************************ protobuf ************************" && \
    apt-get install -y autoconf automake libtool curl make g++ unzip && \
    apt-get update && apt-get install -y net-tools
    # 设置git最小和最大下我速度, 以下步骤大大加快git下载速度
RUN git config --global http.lowSpeedLimit 0 && \
    git config --global http.lowSpeedTime 999999 && \ 
    git config --global core.compression -1 && \
    export GIT_TRACE_PACKET=1 && \
    export GIT_TRACE=1 && \
    export GIT_CURL_VERBOSE=1
    # ifconfig etho mtu 14000
# RUN cd /tmp && \
    # git clone https://github.com/google/protobuf.git
COPY ./Temp/protobuf ./tmp/protobuf
RUN cd /tmp && \
    cd protobuf && \
    git checkout v3.20.3 && \
    git submodule update --init --recursive && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make check && \
    make install && \
    ldconfig && \
    cd /tmp && \
    rm -rf protobuf

#* Install SEAL (3.6)
COPY ./Temp/SEAL ./tmp/SEAL
RUN echo "************************ SEAL ************************" && \
    # git clone -b v3.6.4 https://github.com/microsoft/SEAL.git && \
    cd /tmp/SEAL && \
    cmake -DSEAL_THROW_ON_TRANSPARENT_CIPHERTEXT=OFF -DCMAKE_CXX_STANDARD=17 . && \
    make -j && \
    make install

# #* Install EVA
RUN apt-get update && apt-get install -y libboost-all-dev
RUN pip install numpy
# COPY . ./EVA
# 
# RUN echo "************************ EVA ************************" && \
#     cd EVA && \
#     git submodule update --init

# RUN cd EVA && \
#     mkdir build && cd build && \
#     cmake .. && \
#     make -j

# RUN cd EVA && cd build \
#     python3 -m pip install -e python/ && \
#     python3 tests/all.py

#* Test
# RUN echo "************************ Test ************************"

#! Run with:
#! docker run -v $(pwd):/EVA -it --name eva eva:latest
#! or start a existing container
#! docker start -i eva