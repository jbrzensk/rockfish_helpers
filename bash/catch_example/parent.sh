#!/bin/bash

# Array to hold the PIDs of the spawned scripts
pids=()

# Function to kill all spawned processes
cleanup() {
  echo "Terminating all spawned processes..."
  for pid in "${pids[@]}"; do
    kill "$pid" 2>/dev/null
  done
  exit 0
}

# Trap Ctrl-C (SIGINT) and call cleanup function
trap cleanup SIGINT

# Spawn child scripts
for i in {1..5}; do
  # Each child process runs a simple loop
  ./child.sh "$i" &
  
  # Store the PID of the last spawned process
  pids+=($!)
done

# Wait for all child processes to complete
wait
