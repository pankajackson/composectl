"""
LiteLLM pre-call hook.

1. Greetings ("hi", "hello", "good morning"...) get a canned reply and never
   reach any model (uses LiteLLM's mock_response, so no provider call is made).
2. Any request that carries tools/functions (agents, Home Assistant) is marked
   no-cache, so a stale cached tool call can never trigger a wrong action.
"""

import random
import re

from litellm.integrations.custom_logger import CustomLogger

GREETING_RE = re.compile(
    r"^\s*(hi+|hello+|hey+|hola|namaste|yo|sup|good\s+(morning|afternoon|evening|night)|"
    r"thanks?|thank\s+you|ok(ay)?)\s*[!.?]*\s*$",
    re.IGNORECASE,
)

REPLIES = {
    "greeting": ["Hello! How can I help?", "Hi there! What can I do for you?"],
    "thanks": ["You're welcome!", "Anytime!"],
    "ok": ["Okay!"],
}


def _text_of(message) -> str:
    content = message.get("content", "")
    if isinstance(content, list):  # multimodal: join the text parts only
        return " ".join(p.get("text", "") for p in content if isinstance(p, dict))
    return content or ""


class GreetingHook(CustomLogger):
    async def async_pre_call_hook(self, user_api_key_dict, cache, data, call_type):
        if call_type not in ("completion", "acompletion"):
            return data

        # Rule 2: agents/tool calls are never cached
        if data.get("tools") or data.get("functions"):
            data["cache"] = {"no-cache": True}
            return data

        messages = data.get("messages") or []
        if (
            len(messages) != 1
        ):  # only a bare, first-turn greeting; keep conversations intact
            return data
        msg = messages[0]
        if msg.get("role") != "user":
            return data

        text = _text_of(msg)
        if GREETING_RE.match(text):
            low = text.lower()
            kind = (
                "thanks"
                if "thank" in low
                else "ok" if low.strip().startswith("ok") else "greeting"
            )
            data["mock_response"] = random.choice(REPLIES[kind])
        return data


proxy_handler_instance = GreetingHook()
