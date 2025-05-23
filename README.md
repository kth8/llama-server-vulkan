This repository provides a ready-to-use container image with the [llama.cpp server](https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md) server compiled with Vulkan support and without AVX requirement to run on old hardware. Tested using [i3-3220 CPU](https://www.intel.com/content/www/us/en/products/sku/65693/intel-core-i33220-processor-3m-cache-3-30-ghz/specifications.html?q=CM8063701137502) with [RX 470 GPU](https://www.techpowerup.com/gpu-specs/radeon-rx-470.c2861).

```
docker container run \
  --detach \
  --init \
  --restart always \
  --device /dev/kfd \
  --device /dev/dri \
  --publish 8001:8080 \
  --volume llama:/root/.cache \
  --label io.containers.autoupdate=registry \
  --pull newer \
  --name llama-vulkan \
  --env LLAMA_ARG_HF_REPO=ggml-org/Qwen3-1.7B-GGUF \
  ghcr.io/kth8/llama-server-vulkan:latest
```
Replace `ggml-org/Qwen3-1.7B-GGUF` with your model of choice from [Hugging Face](https://huggingface.co/). Verify if the server is running by going to http://127.0.0.1:8001 in your web browser or using the terminal:
```
curl -X POST http://127.0.0.1:8001/v1/chat/completions \
-H "Content-Type: application/json" \
-d '{"messages":[{"role":"user","content":"Hello"}]}'
```
To load an existing GGUF you can mount that into the container and set the `LLAMA_ARG_MODEL` environment variable to the model file name, by replacing `--env LLAMA_ARG_HF_REPO=ggml-org/Qwen3-1.7B-GGUF` with for example
```
--volume ~/Downloads/DeepSeek-R1-Distill-Qwen-7B-Q4_K_M.gguf:/DeepSeek-R1-Distill-Qwen-7B-Q4_K_M.gguf:z \
--env LLAMA_ARG_MODEL=DeepSeek-R1-Distill-Qwen-7B-Q4_K_M.gguf
```
