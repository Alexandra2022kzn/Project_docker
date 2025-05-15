
FROM ubuntu:22.04

ENV SOFT=/soft

RUN apt-get update && apt-get install -y \
	 wget \
	 bzip2 \  
	 build-essential \
	 cmake \
	 autoconf \
	 zlib1g-dev \
	 libbz2-dev \
	 liblzma-dev \
	 libcurl4-openssl-dev \
	 libncurses-dev

### libdeflate v1.24 (May 12, 2025) ###

RUN wget https://github.com/ebiggers/libdeflate/releases/download/v1.24/libdeflate-1.24.tar.gz && \
    tar -xzf libdeflate-1.24.tar.gz && \
    cd libdeflate-1.24 && \
    cmake -B build && \
    cmake --build build

### HTSlib-1.21 (Sep 12, 2024) ###

RUN wget https://github.com/samtools/htslib/releases/download/1.21/htslib-1.21.tar.bz2 && \
    tar -xjf htslib-1.21.tar.bz2 && \
    cd htslib-1.21 && \
    ./configure && \
    make && \
    make install

### Samtools-1.21 (Sep 12, 2024) ###

RUN wget https://github.com/samtools/samtools/releases/download/1.21/samtools-1.21.tar.bz2 && \
    tar -xjf samtools-1.21.tar.bz2 && \
    cd samtools-1.21 && \
    ./configure && \
    make && \
    make install