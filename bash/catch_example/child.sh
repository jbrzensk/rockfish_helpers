#!/bin/bash

# Take the script number as an argument
script_num=$1

# Simulate some long-running work
while true; do
  echo "Child script $script_num is running..."
  sleep 2
done
