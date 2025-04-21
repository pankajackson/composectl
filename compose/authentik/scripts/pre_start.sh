#!/bin/bash

echo "PG_PASS=$(openssl rand -base64 36 | tr -d '\n')" >>.env
echo "AUTHENTIK_SECRET_KEY=$(openssl rand -base64 60 | tr -d '\n')" >>.env
echo "AUTHENTIK_ERROR_REPORTING__ENABLED=true" >>.env
echo "# COMPOSE_PORT_HTTP=80" >>.env
echo "# COMPOSE_PORT_HTTPS=443" >>.env
