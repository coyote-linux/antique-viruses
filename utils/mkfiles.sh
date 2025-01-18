#!/bin/bash

# Check if correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <file_list.txt> <target_directory>"
    exit 1
fi

# Assign arguments to variables
file_list="$1"
target_dir="$2"

# Check if the file list exists
if [ ! -f "$file_list" ]; then
    echo "Error: File list '$file_list' not found."
    exit 1
fi

# Check if the target directory exists, create it if not
if [ ! -d "$target_dir" ]; then
    mkdir -p "$target_dir"
fi

# Read file list and create empty files in the target directory
while IFS= read -r filename; do
    if [ -n "$filename" ]; then
        touch "$target_dir/$filename"
    fi
done < "$file_list"

echo "Files created successfully in '$target_dir'."
