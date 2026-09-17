FROM n8nio/runners:stable

USER root

ARG N8N_RUNNERS_PYTHON_PACKAGES
ARG N8N_RUNNERS_NODE_PACKAGES

ARG N8N_RUNNERS_STDLIB_ALLOW
ARG N8N_RUNNERS_EXTERNAL_ALLOW
ARG N8N_RUNNERS_NODE_BUILTIN_ALLOW
ARG N8N_RUNNERS_NODE_EXTERNAL_ALLOW

# ------------------------------------------------------------
# Runner configuration generator
# ------------------------------------------------------------

COPY n8n-task-runners.json /runner/n8n-task-runners.json
COPY generate-runner-json.sh /runner/generate-runner-json.sh

RUN chmod +x /runner/generate-runner-json.sh

# ------------------------------------------------------------
# Python packages
# ------------------------------------------------------------

RUN if [ -n "${N8N_RUNNERS_PYTHON_PACKAGES}" ]; then \
    echo "Installing Python packages: ${N8N_RUNNERS_PYTHON_PACKAGES}" && \
    uv pip install \
        --python /opt/runners/task-runner-python/.venv/bin/python \
        ${N8N_RUNNERS_PYTHON_PACKAGES}; \
    fi

# ------------------------------------------------------------
# Node packages
# ------------------------------------------------------------

WORKDIR /opt/runners/task-runner-javascript

RUN if [ -n "${N8N_RUNNERS_NODE_PACKAGES}" ]; then \
    echo "Installing Node packages: ${N8N_RUNNERS_NODE_PACKAGES}" && \
    node /usr/local/lib/node_modules/pnpm/bin/pnpm.cjs \
        add ${N8N_RUNNERS_NODE_PACKAGES}; \
    fi

# ------------------------------------------------------------
# Generate final runner configuration
# ------------------------------------------------------------

WORKDIR /runner

RUN /runner/generate-runner-json.sh

# ------------------------------------------------------------

USER runner