FROM debian:10

RUN apt update -y \
    && apt install -y git openssl libtool autoconf subversion git cvs wget pkg-config build-essential libgsm1 libssl-dev libxml2-dev libspeex-dev libspeexdsp-dev

WORKDIR /usr/src

RUN git clone https://github.com/cisco/libsrtp/ \
    && cd libsrtp \
    && git checkout v1.5.4 \
    && CFLAGS="-fPIC" ./configure --enable-pic && make && make install

RUN git clone https://github.com/DoubangoTelecom/doubango \
    && cd doubango \
    && ./autogen.sh \
    && ./configure --with-ssl --with-srtp --with-speexdsp \
    && make \
    && make install

RUN git clone https://github.com/DoubangoTelecom/webrtc2sip \
    && export PREFIX=/opt/webrtc2sip \
    && cd webrtc2sip \
    && ./autogen.sh \
    && LDFLAGS=-ldl ./configure --prefix=$PREFIX \
    && make \
    && make install

ENV LD_LIBRARY_PATH=/usr/local/lib64
WORKDIR /usr/src/webrtc2sip/

CMD "/usr/src/webrtc2sip/webrtc2sip" "--config=/etc/webrtc2sip/config.xml"
