# Local AI stack

This Compose project runs Ollama, LiteLLM, Open WebUI, PostgreSQL and Redis. ComfyUI, Tabby and Wyoming Whisper/Piper are optional profiles. LiteLLM provides the OpenAI-compatible API at `http://<host>:4000/v1`.

This is an inference stack, not the complete LinuxAstra platform in the planning brief. It does not include a custom FastAPI gateway, Qdrant/semantic cache, application-level user policies, or provider quota accounting. LiteLLM's configured response cache is exact-match only; send `"cache": {"no-cache": true}` for requests that must bypass it. Tool calls are automatically excluded by the pre-call hook.

## Start

Run these commands from this directory:

```sh
cp env.example .env
```

Edit `.env` and replace all four secret placeholders with unique random values. Hexadecimal secrets work well with the current Redis command and PostgreSQL connection URL. Keep provider API keys blank when unused. `.env` contains secrets and must not be committed.

For NVIDIA GPU inference, install the NVIDIA driver and NVIDIA Container Toolkit on the Docker host first. Then start the core services:

```sh
docker compose up -d
```

Optional components can be started by profile:

```sh
docker compose --profile comfy up -d
docker compose --profile tabby up -d
docker compose --profile voice up -d
```

To enable several optional profiles together, for example `docker compose --profile comfy --profile tabby up -d`. The core services start along with any selected profile.

## First local model

The model names in `litellm/config.yaml` and `tabby/config.toml` must exist in Ollama. Pull the configured chat and embedding models after Ollama starts:

```sh
docker compose exec ollama ollama pull qwen3:14b
docker compose exec ollama ollama pull nomic-embed-text
```

For Tabby completion, pull its configured completion model too:

```sh
docker compose exec ollama ollama pull qwen2.5-coder:1.5b-base
```

Check GPU visibility with `docker compose exec ollama nvidia-smi` (if the image includes the utility) or inspect `docker compose logs ollama`; check downloaded models with `docker compose exec ollama ollama list`.

## Endpoints

- Open WebUI: `http://<host>:3000`
- LiteLLM API: `http://<host>:4000/v1`
- Ollama API: `http://<host>:11434`
- ComfyUI: `http://<host>:8188` when the `comfy` profile is enabled
- Tabby: `http://<host>:8081` when the `tabby` profile is enabled
- Whisper / Piper: ports `10300` / `10200` when the `voice` profile is enabled

The LiteLLM master key is the API key for the configured models. The `local` alias stays on Ollama and does not fail over to a cloud provider. The `smart` alias tries the configured cloud deployments in their listed order and falls back to `local`. Provider model names and free-tier availability change; verify them with each provider before relying on them.

All published ports currently bind to every host interface. Restrict access with host firewall rules or change the port bindings before exposing this stack beyond a trusted LAN. Do not expose ComfyUI or Ollama directly to the public internet. Open WebUI's first account is administrator, so create it on a trusted network.

## GPU memory

Ollama defaults to one loaded model and one parallel request to reduce contention with ComfyUI. Both settings are adjustable in `.env`. ComfyUI and Ollama share the GPU; start only the workload you need when VRAM is limited. Ollama's short keep-alive allows idle models to unload after requests.

## Configuration files

- `docker-compose.yml`: services, profiles, GPU access and persistent data mounts
- `litellm/config.yaml`: model aliases, provider order, fallback and response cache
- `litellm/greeting_hook.py`: simple greeting responses and tool-call cache bypass
- `tabby/config.toml`: IDE completion, chat and embedding connections to Ollama
- `env.example`: environment variables and secret placeholders
