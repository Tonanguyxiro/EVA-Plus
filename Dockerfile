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
    apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python3.10 python3.10-dev python3.10-distutils python3-pip && \
    apt-get install -y autoconf automake libtool curl make g++ unzip && \
    apt-get install -y libomp-dev && \
    apt-get install -y fish
 
RUN apt-get install -y clang && \
    update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 && \
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++ 100

#* Install protobuf (v3.20.3)
RUN echo "************************ protobuf ************************" && \
    apt-get install -y autoconf automake libtool curl make g++ unzip && \
    cd /tmp && \
    git clone https://github.com/google/protobuf.git && \
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

#* Install EVA
COPY . ./EVA

RUN echo "************************ EVA ************************" && \
    cd EVA && \
    git submodule update --init
# RUN cmake . && \
#     make -j

# RUN cd EVA && \
#     python3 -m pip install -e python/ && \
#     python3 tests/all.py

#* Test
RUN echo "************************ Test ************************"