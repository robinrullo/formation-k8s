#!/usr/bin/env sh

handle_sigterm() {
  echo "Caught SIGTERM signal!"
  exit 0
}

handle_sigint() {
  echo "Caught SIGINT signal!"
  exit 0
}

trap handle_sigterm SIGTERM
trap handle_sigint SIGINT

echo "Some other initialization steps wrapped with the custom entrypoint..."

# Use exec to replace the shell process with the Node.js process (nodejs app must be the 1st process in linux namespace)
exec node "$@"
