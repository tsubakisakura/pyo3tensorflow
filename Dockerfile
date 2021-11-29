FROM tensorflow/tensorflow:2.7.0 AS build
WORKDIR /workdir

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

RUN apt-get update \
 && apt-get install -y \
        libssl-dev \
 && apt-get clean
ENV OPENSSL_LIB_DIR=/usr/lib/x86_64-linux-gnu/
ENV OPENSSL_INCLUDE_DIR=/usr/include/openssl

COPY ./Cargo.toml ./Cargo.lock ./
RUN mkdir ./src
RUN echo "fn main() {}" > ./src/main.rs
RUN cargo build --release

COPY ./src/ ./src
RUN touch ./src/main.rs
RUN cargo build --release


FROM tensorflow/tensorflow:2.7.0
WORKDIR /workdir

RUN apt-get update \
 && apt-get install -y \
        libssl-dev \
 && apt-get clean
ENV OPENSSL_LIB_DIR=/usr/lib/x86_64-linux-gnu/
ENV OPENSSL_INCLUDE_DIR=/usr/include/openssl

RUN pip install --upgrade pip \
 && pip install --no-cache-dir \
        google-cloud-storage
COPY --from=build /workdir/target/release/build/tensorflow-sys-43013d59429991b7/out/libtensorflow.so.2 ./target/release/
COPY --from=build /workdir/target/release/build/tensorflow-sys-43013d59429991b7/out/libtensorflow_framework.so.2 ./target/release/
COPY --from=build /workdir/target/release/pyo3tensorflow ./target/release/
ENV LD_LIBRARY_PATH=/workdir/target/release
CMD ["/bin/bash"]
