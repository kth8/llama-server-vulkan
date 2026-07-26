FROM almalinux:9-minimal AS builder
RUN microdnf -y install vulkan-loader-devel glslc git gcc-c++ cmake libcurl-devel openssl-devel spirv-headers-devel

RUN git clone --depth 1 https://github.com/ggml-org/llama.cpp.git

RUN cmake llama.cpp -B llama.cpp/build -DBUILD_SHARED_LIBS=OFF -D GGML_VULKAN=ON -DLLAMA_OPENSSL=ON \
    -DCMAKE_C_FLAGS="-march=sandybridge -mtune=generic -mno-avx -mno-avx2 -mno-bmi -mno-bmi2" \
    -DCMAKE_CXX_FLAGS="-march=sandybridge -mtune=generic -mno-avx -mno-avx2 -mno-bmi -mno-bmi2"

RUN cmake --build llama.cpp/build --config Release -j --target llama-server

FROM almalinux:9-minimal

RUN microdnf -y install mesa-vulkan-drivers libgomp && \
    microdnf clean all && \
    rm -rf /var/cache/dnf

COPY --from=builder /llama.cpp/build/bin/llama-server .
ENTRYPOINT ["/llama-server"]
