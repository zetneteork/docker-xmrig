FROM debian:stable-slim AS BUILD
COPY src/donate.h /donate.h
RUN \
    apt-get update &&\
    apt-get install -y git build-essential cmake automake libtool autoconf wget &&\
    git clone https://github.com/xmrig/xmrig.git &&\
    mv /donate.h /xmrig/src/donate.h &&\
    cat /xmrig/src/donate.h &&\
    mkdir xmrig/build && cd xmrig/scripts &&\
    ./build_deps.sh && cd ../build &&\
    cmake .. -DXMRIG_DEPS=scripts/deps &&\
    make -j$(nproc) &&\
    ldd xmrig &&\
    /xmrig/build/xmrig --version &&\
    /xmrig/build/xmrig --version | grep -i xmrig | cut -f 2 -d ' '

FROM debian:stable-slim
WORKDIR /xmrig
COPY --from=BUILD /xmrig/build/libxmrig-asm.a /xmrig/libxmrig-asm.a
COPY --from=BUILD /xmrig/build/xmrig /xmrig/xmrig
COPY src/config.json /xmrig/config.json
EXPOSE 8080
RUN \
    echo "PATH=/xmrig:${PATH}" >> ~/.profile &&\
    /xmrig/xmrig --version | grep -i xmrig | cut -f 2 -d ' '
CMD ["/xmrig/xmrig"]