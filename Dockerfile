FROM centos:7.8.2003
RUN yum update -y &&\
    yum install -y make libtool autoconf subversion git cvs wget libogg-devel gcc gcc-c++ pkgconfig 

RUN git clone https://github.com/DoubangoTelecom/webrtc2sip.git

RUN git clone https://github.com/cisco/libsrtp/ && cd libsrtp && git checkout v1.5.2 && CFLAGS="-fPIC" ./configure --enable-pic && make shared_library && make install

RUN wget https://www.openssl.org/source/openssl-1.1.1g.tar.gz &&\
    tar -xvzf openssl-1.1.1g.tar.gz && cd openssl-1.1.1g &&\
    ./config shared --prefix=/usr/local --openssldir=/usr/local/openssl &&\
    make && make install

RUN yum install -y speex-devel

RUN wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz &&\
    tar -xvzf yasm-1.2.0.tar.gz && \
    cd yasm-1.2.0 &&\
    ./configure && make && make install

RUN yum install -y libvpx-devel

#RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools &&\
#    cd depot_tools &&\
#    PATH=$PATH:$(pwd) &&\
#    ./gclient https://chromium.googlesource.com/libyuv/libyuv &&\
#    ./gclient sync &&\
#    make -j6 V=1 -r libyuv BUILDTYPE=Release &&\
#    make -j6 V=1 -r libjpeg BUILDTYPE=Release &&\
#    cp out/Release/obj.target/libyuv.a /usr/local/lib &&\
#    cp out/Release/obj.target/third_party/libjpeg_turbo/libjpeg_turbo.a /usr/local/lib &&\
#    mkdir --parents /usr/local/include/libyuv/libyuv &&\
#    cp -rf include/libyuv.h /usr/local/include/libyuv &&\
#    cp -rf include/libyuv/*.h /usr/local/include/libyuv/libyuv

#RUN git clone git://opencore-amr.git.sourceforge.net/gitroot/opencore-amr/opencore-amr &&\
#    autoreconf --install && ./configure && make && make install

RUN wget http://downloads.xiph.org/releases/opus/opus-1.0.2.tar.gz && tar -xvzf opus-1.0.2.tar.gz && cd opus-1.0.2 && ./configure --with-pic --enable-float-approx && make && make install

RUN yum install -y gsm-devel

#RUN svn co https://g729.googlecode.com/svn/trunk/ g729 &&\
#    cd g729 &&\
#    ./autogen.sh && ./configure --enable-static --disable-shared &&\
#    make && make install

#RUN svn co http://doubango.googlecode.com/svn/branches/2.0/doubango/thirdparties/scripts/ilbc &&\
#    cd libc &&\
#    wget http://www.ietf.org/rfc/rfc3951.txt &&\
#    awk -f extract.awk rfc3951.txt &&\
#    ./autogen.sh && ./configure &&\
#    make && make install

#RUN wget ftp://ftp.videolan.org/pub/x264/snapshots/last_x264.tar.bz2 &&\
#    tar -xvjf last_x264.tar.bz2 &&\
#    cd x264-snapshot-* &&\
#    ./configure --enable-shared --enable-pic && make && make install

RUN cd /usr/src &&\
git clone https://github.com/FFmpeg/FFmpeg.git ffmpeg &&\
cd ffmpeg &&\
git checkout release/1.2 &&\
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
  --enable-decoder=h263 &&\
  make &&\
  make install

RUN cd /usr/src &&\
    git clone https://github.com/DoubangoTelecom/doubango &&\
    cd doubango &&\
    ./autogen.sh &&\
    ./configure  --with-ssl --with-srtp --with-vpx --with-speex --with-speexdsp --with-gsm &&\
    make &&\
    make install


RUN yum install -y libxml2-devel 

RUN cd /usr/src &&\
git clone https://github.com/DoubangoTelecom/webrtc2sip &&\
export PREFIX=/opt/webrtc2sip &&\
cd webrtc2sip &&\
./autogen.sh &&\
LDFLAGS=-ldl ./configure --prefix=$PREFIX &&\
make &&\
make install &&\
cp -f ./config.xml $PREFIX/sbin/config.xml



ENV LD_LIBRARY_PATH=/usr/local/lib64
WORKDIR /usr/src/webrtc2sip/

ENTRYPOINT ./webrtc2sip

