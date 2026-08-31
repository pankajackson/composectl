#!/usr/bin/env bash

read -rsp "Password: " PASSWORD
echo

HASH=$(htpasswd -nbBC 10 "" "$PASSWORD" 2>/dev/null | tr -d ':\n' | sed 's/$2y/$2a/')
TOKEN=$(openssl rand -hex 32)

echo
echo "Password Hash:"
echo "$HASH"

echo
echo "Token:"
echo "$TOKEN"