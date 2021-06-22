FROM centos:7

RUN yum update -y \
    && yum install -y make libtool autoconf subversion git cvs wget libogg-devel gcc gcc-c++ pkgconfig 

RUN git clone https://github.com/DoubangoTelecom/webrtc2sip.git

RUN git clone https://github.com/cisco/libsrtp/ \
    && cd libsrtp && git checkout v1.5.2 && CFLAGS="-fPIC" ./configure --enable-pic \
    && make shared_library \
    && make install

RUN wget https://www.openssl.org/source/openssl-1.1.1g.tar.gz \
    && tar -xvzf openssl-1.1.1g.tar.gz && cd openssl-1.1.1g \
    && ./config shared --prefix=/usr/local --openssldir=/usr/local/openssl \
    && make \
    && make install

RUN yum install -y speex-devel

RUN wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz \
    && tar -xvzf yasm-1.2.0.tar.gz \
    && cd yasm-1.2.0 \
    && ./configure && make \
    && make install

RUN yum install -y libvpx-devel

RUN wget http://downloads.xiph.org/releases/opus/opus-1.0.2.tar.gz \
    && tar -xvzf opus-1.0.2.tar.gz && cd opus-1.0.2 && ./configure --with-pic --enable-float-approx && make && make install

RUN yum install -y gsm-devel

RUN yum install ffmpeg

RUN cd /usr/src \
    && git clone https://github.com/FFmpeg/FFmpeg.git ffmpeg \
    && cd ffmpeg \
    && git checkout release/1.2 \
        ./configure \
        --extra-cflags="-fPIC" \
        --extra-ldflags="-lpthread" \
        --enable-pic \
        --enable-memalign-hack \
        --enable-pthreads \
        --enable-shared \
        --disable-static \
        --disable-network \
        --enable-pthreads \
        --disable-ffmpeg \
        --disable-ffplay \
        --disable-ffserver \
        --disable-ffprobe \
        --enable-gpl \
        --enable-nonfree \
        --disable-debug \
        --enable-decoder=h264 \
        --enable-encoder=h263 \
        --enable-encoder=h263p \
        --enable-decoder=h263 \
    && make \
    && make install

RUN cd /usr/src \
    && git clone https://github.com/DoubangoTelecom/doubango \
    && cd doubango \
    &&./autogen.sh \
    && ./configure  --with-ssl --with-srtp --with-vpx --with-speex --with-speexdsp --with-gsm \
    && make \
    && make install

RUN yum install -y libxml2-devel 

RUN cd /usr/src \
    && git clone https://github.com/DoubangoTelecom/webrtc2sip \
    && export PREFIX=/opt/webrtc2sip \
    && cd webrtc2sip \
    && ./autogen.sh \
    && LDFLAGS=-ldl ./configure --prefix=$PREFIX \
    && make \
    && make install \
    && cp -f ./config.xml $PREFIX/sbin/config.xml

ENV LD_LIBRARY_PATH=/usr/local/lib64
WORKDIR /usr/src/webrtc2sip/

ENTRYPOINT ./webrtc2sip

