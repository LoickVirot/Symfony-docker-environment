#!/bin/bash

ENV_FILE=.env

if [ ! -f "$ENV_FILE" ]; then
  echo "=== Create .env file"
  cp .env.example .env
else
  echo "=== .env file already exists, skipping."
fi

