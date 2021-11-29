FROM tensorflow/tensorflow:2.7.0 AS build
WORKDIR /workdir

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

COPY ./Cargo.toml ./Cargo.lock ./
RUN mkdir ./src
RUN echo "fn main() {}" > ./src/main.rs
RUN cargo build --release

COPY ./src/ ./src
RUN touch ./src/main.rs
RUN cargo build --release

FROM tensorflow/tensorflow:2.7.0
WORKDIR /workdir
RUN pip install --upgrade pip \
 && pip install --no-cache-dir \
        google-cloud-storage
COPY --from=build /workdir/target/release/build/tensorflow-sys-43013d59429991b7/out/libtensorflow.so.2 ./target/release/
COPY --from=build /workdir/target/release/build/tensorflow-sys-43013d59429991b7/out/libtensorflow_framework.so.2 ./target/release/
COPY --from=build /workdir/target/release/pyo3tensorflow ./target/release/
CMD ["/bin/bash"]
