#!/bin/sh

set -eu

TEMPLATE="/runner/n8n-task-runners.json"
OUTPUT="/etc/n8n-task-runners.json"

echo "Generating task runner configuration..."

sed \
  -e "s|__N8N_RUNNERS_STDLIB_ALLOW__|${N8N_RUNNERS_STDLIB_ALLOW:-}|g" \
  -e "s|__N8N_RUNNERS_EXTERNAL_ALLOW__|${N8N_RUNNERS_EXTERNAL_ALLOW:-}|g" \
  -e "s|__N8N_RUNNERS_NODE_BUILTIN_ALLOW__|${N8N_RUNNERS_NODE_BUILTIN_ALLOW:-}|g" \
  -e "s|__N8N_RUNNERS_NODE_EXTERNAL_ALLOW__|${N8N_RUNNERS_NODE_EXTERNAL_ALLOW:-}|g" \
  "$TEMPLATE" > "$OUTPUT"

echo "Generated: $OUTPUT"