FROM debian:9
MAINTAINER Eduardo Silva <zedudu@gmail.com>

RUN apt-get update && apt-get install -y  \
    procps \
    autoconf \
    automake \
    bzip2 \
    g++ \
    git \
    gstreamer1.0-plugins-good \
    gstreamer1.0-tools \
    gstreamer1.0-pulseaudio \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-ugly  \
    gfortran \
    libatlas3-base \
    libgstreamer1.0-dev \
    libtool-bin \
    make \
    python2.7 \
    python3 \
    python-pip \
    python-yaml \
    python-simplejson \
    python-gi \
    subversion \
    unzip \
    wget \
    build-essential \
    python-dev \
    sox \
    zlib1g-dev && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    pip install ws4py==0.3.2 && \
    pip install tornado==4.5.3 && \
    ln -s /usr/bin/python2.7 /usr/bin/python ; ln -s -f bash /bin/sh

WORKDIR /opt

RUN wget http://www.digip.org/jansson/releases/jansson-2.7.tar.bz2 && \
    bunzip2 -c jansson-2.7.tar.bz2 | tar xf -  && \
    cd jansson-2.7 && \
    ./configure && make -j $(nproc) && make check &&  make install && \
    echo "/usr/local/lib" >> /etc/ld.so.conf.d/jansson.conf && ldconfig && \
    rm /opt/jansson-2.7.tar.bz2 && rm -rf /opt/jansson-2.7

RUN git clone https://github.com/DaHye9/kaldi && \
    cd /opt/kaldi/tools && \
    make -j $(nproc) && \
    ./install_portaudio.sh && \
    /opt/kaldi/tools/extras/install_mkl.sh && \
    cd /opt/kaldi/src && ./configure --mathlib=ATLAS --shared && \
    sed -i '/-g # -O0 -DKALDI_PARANOID/c\-O3 -DNDEBUG' kaldi.mk && \
    make clean -j $(nproc) && make -j $(nproc) depend && make -j $(nproc) && \
    cd /opt/kaldi/src/online && make depend -j $(nproc) && make -j $(nproc) && \
    cd /opt/kaldi/src/gst-plugin && sed -i 's/-lmkl_p4n//g' Makefile && make depend -j $(nproc) && make -j $(nproc) && \
    cd /opt && \
    git clone https://github.com/DaHye9/gst-kaldi-nnet2-online.git && \
    cd /opt/gst-kaldi-nnet2-online/src && \
    sed -i '/KALDI_ROOT?=\/home\/tanel\/tools\/kaldi-trunk/c\KALDI_ROOT?=\/opt\/kaldi' Makefile && \
    make depend -j $(nproc) && make -j $(nproc) && \
    rm -rf /opt/gst-kaldi-nnet2-online/.git/ && \
    find /opt/gst-kaldi-nnet2-online/src/ -type f -not -name '*.so' -delete && \
    rm -rf /opt/kaldi/.git && \
    rm -rf /opt/kaldi/egs/ /opt/kaldi/windows/ /opt/kaldi/misc/ && \
    find /opt/kaldi/src/ -type f -not -name '*.so' -delete && \
    find /opt/kaldi/tools/ -type f \( -not -name '*.so' -and -not -name '*.so*' \) -delete && cd /opt

RUN pip install futures

# Build Python3.7 and pip3
#RUN mkdir /opt/python3 && cd /opt/python3 && \
#    apt-get install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev \
#        libnss3-dev libssl-dev libreadline-dev libffi-dev curl libbz2-dev && \
#    curl -O https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tar.xz && \
#    tar -xf Python-3.7.3.tar.xz && \
#    cd Python-3.7.3 && ./configure --enable-optimizations && make -j 6 && \
#    make altinstall
#
#RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
#    python3.7 get-pip.py
#
#RUN pip3 install git+https://github.com/haven-jeon/PyKoSpacing.git

COPY start.sh start_worker.sh stop.sh /opt/
COPY kaldi-gstreamer-server /opt/kaldi-gstreamer-server/

RUN chmod +x /opt/start.sh && \
    chmod +x /opt/start_worker.sh && \
    chmod +x /opt/stop.sh
