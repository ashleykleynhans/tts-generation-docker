# Docker image for TTS Generation Web UI (Bark, MusicGen + AudioGen, Tortoise, RVC, Vocos, Demucs, SeamlessM4T, MAGNeT)

## Installs

* Ubuntu 22.04 LTS
* CUDA 11.8
* Python 3.10.12
* [TTS Generation Web UI](
  https://github.com/rsxdalv/tts-generation-webui)
* Torch 2.1.2
* [runpodctl](https://github.com/runpod/runpodctl)
* [croc](https://github.com/schollz/croc)
* [rclone](https://rclone.org/

## Available on RunPod

This image is designed to work on [RunPod](https://runpod.io?ref=2xxro4sy).
You can use my custom [RunPod template](
https://runpod.io/gsc?template=j898rhd8t6&ref=2xxro4sy)
to launch it on RunPod.

## Running Locally

### Install Nvidia CUDA Driver

- [Linux](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html)
- [Windows](https://docs.nvidia.com/cuda/cuda-installation-guide-microsoft-windows/index.html)

### Start the Docker container

```bash
docker run -d \
  --gpus all \
  -v /workspace \
  -p 3000:3001 \
  -p 8888:8888 \
  -e JUPYTER_PASSWORD=Jup1t3R! \
  ashleykza/tts-generation:latest
```

You can obviously substitute the image name and tag with your own.

## Community and Contributing

Pull requests and issues on [GitHub](https://github.com/ashleykleynhans/tts-generation-docker)
are welcome. Bug fixes and new features are encouraged.

You can contact me and get help with deploying your container
to RunPod on the RunPod Discord Server below,
my username is **ashleyk**.

<a target="_blank" href="https://discord.gg/pJ3P2DbUUq">![Discord Banner 2](https://discordapp.com/api/guilds/912829806415085598/widget.png?style=banner2)</a>

## Appreciate my work?

<a href="https://www.buymeacoffee.com/ashleyk" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
