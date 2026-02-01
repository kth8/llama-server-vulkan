FROM almalinux:9-minimal AS builder
RUN microdnf -y install vulkan-loader-devel glslc git gcc-c++ cmake libcurl-devel openssl-devel

RUN git clone --depth 1 https://github.com/ggml-org/llama.cpp.git && \
    sed -i 's#^\(.*\[GGML_TYPE_IQ1_M\].*\)$#// \1#' /llama.cpp/ggml/src/ggml-vulkan/ggml-vulkan.cpp

RUN cmake llama.cpp -B llama.cpp/build -DBUILD_SHARED_LIBS=OFF -D GGML_VULKAN=ON -DLLAMA_OPENSSL=ON \
    -DCMAKE_C_FLAGS="-march=sandybridge -mtune=generic -mno-avx -mno-avx2 -mno-bmi -mno-bmi2" \
    -DCMAKE_CXX_FLAGS="-march=sandybridge -mtune=generic -mno-avx -mno-avx2 -mno-bmi -mno-bmi2"

RUN cmake --build llama.cpp/build --config Release -j --target llama-server

FROM almalinux:9-minimal

RUN microdnf -y install mesa-vulkan-drivers libgomp && \
    microdnf clean all && \
    rm -rf /var/cache/dnf

COPY --from=builder /llama.cpp/build/bin/llama-server .

ENV LLAMA_ARG_HOST=0.0.0.0
ENV LLAMA_ARG_PORT=8080
ENV LLAMA_ARG_CTX_SIZE=8192
ENV LLAMA_ARG_N_GPU_LAYERS=99

CMD ["/llama-server"]
