# LiteLLM + Ollama

This is a small local LiteLLM gateway with Ollama, Redis response caching, and Open WebUI. Gemini and Groq are optional providers.

## Start

1. Copy `.env.example` to `.env` and set `LITELLM_MASTER_KEY` and `WEBUI_SECRET_KEY` to random values. Add Gemini and/or Groq API keys for the cloud models you want to use.
2. Start the services: `docker compose up -d`.
3. Pull the default Ollama model: `docker compose exec ollama ollama pull qwen3:8b`.
4. Open WebUI at `http://localhost:3000`. Select `smart` to use the auto router, or choose `local-chat`, `gemini-flash`, or `groq-llama` to use a provider directly.

The LiteLLM OpenAI compatible API is at `http://localhost:4000/v1`. Use `LITELLM_MASTER_KEY` as its bearer key.

## Routing policy

Edit `litellm/config.yaml` under the `smart` model's `complexity_router_config.tiers` mapping. The built-in heuristic classifies each request as `SIMPLE`, `MEDIUM`, `COMPLEX`, or `REASONING`; each tier points to one of the model names declared above. The default is `local-chat` if classification does not produce a tier. This is complexity based routing, not a user-defined topic classifier. For predictable provider selection, call a named model directly.

Response caching is exact request matching and uses the included Redis service. Ollama models are not downloaded automatically; pull the configured model after startup. Change `local-chat`'s model in `litellm/config.yaml` and the pull command if your hardware needs a smaller or different model.
