#!/bin/bash

# Usage: ./find_files.sh /path/to/specific/folder

# Check if folder path is provided
if [ -z "$1" ]; then
  echo "Usage: $0 /path/to/specific/folder"
  exit 1
fi

FOLDER=$1

# Find files containing the regex and print their absolute paths
grep -ril "<convert.*dart.*>" "$FOLDER" | while read -r file; do
  # Print the absolute path of each file
  echo "$(realpath "$file")"
done

