FROM ubuntu:22.04

ENV SOFT=/soft

ENV PATH="${SOFT}/libdeflate_br250512/bin:${SOFT}/htslib_br240912/bin:${SOFT}/samtools_br240912/bin:${SOFT}/bcftools_br240912/bin:${SOFT}/vcftools_br250515/bin:$PATH"
ENV LD_LIBRARY_PATH="${SOFT}/libdeflate_br250512/lib:${SOFT}/htslib_br240912/lib:$LD_LIBRARY_PATH"

ENV SAMTOOLS="${SOFT}/samtools_br240912/bin/samtools"
ENV VCFTOOLS="${SOFT}/vcftools_br250515/bin/vcftools"
ENV BCFTOOLS="${SOFT}/bcftools_br240912/bin/bcftools"

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
	libncurses-dev \
    	libperl-dev \
    	libgsl0-dev \
    	pkg-config && \
	apt-get clean && rm -rf /var/lib/apt/lists/*


### libdeflate v1.24 (May 12, 2025) ###

RUN wget https://github.com/ebiggers/libdeflate/releases/download/v1.24/libdeflate-1.24.tar.gz && \
    tar -xzf libdeflate-1.24.tar.gz && \
    cd libdeflate-1.24 && \
    cmake -B build -DCMAKE_INSTALL_PREFIX=${SOFT}/libdeflate_br250512 && \
    cmake --build build && \
    cmake --install build && \
    cd .. && rm -rf libdeflate-1.24 libdeflate-1.24.tar.gz

### HTSlib-1.21 (Sep 12, 2024) ###

RUN wget https://github.com/samtools/htslib/releases/download/1.21/htslib-1.21.tar.bz2 && \
    tar -xjf htslib-1.21.tar.bz2 && \
    cd htslib-1.21 && \
    ./configure CPPFLAGS="-I/${SOFT}/libdeflate_br250512/include" \
    LDFLAGS="-L/${SOFT}/libdeflate_br250512/lib -Wl,-R/soft/libdeflate_br250512/lib" \ 
    --prefix=${SOFT}/htslib_br240912 && \
    make -j$(nproc) && \
    make install && \
    cd .. && rm -rf htslib-1.21 htslib-1.21.tar.bz2

### Samtools-1.21 (Sep 12, 2024) ###

RUN wget https://github.com/samtools/samtools/releases/download/1.21/samtools-1.21.tar.bz2 && \
    tar -xjf samtools-1.21.tar.bz2 && \
    cd samtools-1.21 && \
    ./configure --prefix=${SOFT}/samtools_br240912 --with-htslib=${SOFT}/htslib_br240912 && \
    make -j$(nproc) && \
    make install && \
    cd .. && rm -rf samtools-1.21 samtools-1.21.tar.bz2

### Bcftools-1.21 (Sep 12, 2024) ###

RUN wget https://github.com/samtools/bcftools/releases/download/1.21/bcftools-1.21.tar.bz2 && \
    tar -xjf bcftools-1.21.tar.bz2 && \
    cd bcftools-1.21 && \
    ./configure --prefix=${SOFT}/bcftools_br240912 --with-htslib=${SOFT}/htslib_br240912 && \
    make -j$(nproc) && \
    make install && \
    cd .. && rm -rf bcftools-1.21 bcftools-1.21.tar.bz2

### Vcftools-0.1.17 (May 15, 2025) ###

RUN wget https://github.com/vcftools/vcftools/releases/download/v0.1.17/vcftools-0.1.17.tar.gz && \
    tar -xzf vcftools-0.1.17.tar.gz && \
    cd vcftools-0.1.17 && \
    ./configure --prefix=${SOFT}/vcftools_br250515 && \
    make -j$(nproc) && \
    make install && \
    cd .. && rm -rf vcftools-0.1.17 vcftools-0.1.17.tar.gz