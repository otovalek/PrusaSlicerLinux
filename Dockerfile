FROM debian:trixie-slim AS build
RUN apt-get update && apt-get upgrade --yes
RUN apt-get install --yes --no-install-recommends ca-certificates libtool git build-essential automake cmake texinfo libglu1-mesa-dev libdbus-1-dev libwebkit2gtk-4.1-dev

ARG VERSION=2.9.4
ADD https://github.com/prusa3d/PrusaSlicer.git#version_$VERSION /source

WORKDIR /source
ENV LANG=C.utf8 CXXFLAGS=--no-warnings

RUN cmake -S deps -B deps/build -DDEP_WX_GTK3=ON
RUN cmake --build deps/build --parallel 4

RUN cmake -S . -B build -DSLIC3R_STATIC=1 -DSLIC3R_GTK=3 -DSLIC3R_PCH=OFF -DCMAKE_PREFIX_PATH=/source/deps/build/destdir/usr/local -DCMAKE_INSTALL_PREFIX=/destination/PrusaSlicer-$VERSION
RUN cmake --build build --target install --parallel `nproc`
RUN tar --create --xz --verbose --directory=/destination --file /destination/PrusaSlicer-$VERSION.tar.xz PrusaSlicer-$VERSION

FROM scratch
COPY --from=build /destination/PrusaSlicer-*.tar.xz /
