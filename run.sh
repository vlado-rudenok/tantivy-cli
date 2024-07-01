#!/bin/bash

# List of language directories from the given list, sorted alphabetically
language_folders=("af" "de" "en" "es" "fr" "hi" "hu" "id" "it" "ja" "lug" "mya" "nl" "pl" "pt" "ro" "ru" "run" "rw" "sr" "sw" "ta" "te" "teo" "yor" "zh")

# Ensure the output directory exists
output_dir="output"
if [ ! -d "$output_dir" ]; then
  mkdir -p "$output_dir"
  if [ $? -ne 0 ]; then
    echo "Error creating output directory. Exiting."
    exit 1
  fi
fi

# List the contents of the input directory for debugging
echo "Contents of the input directory:"
ls input

# Loop through each folder
for folder in "${language_folders[@]}"; do
  # Define the path to the folder
  folder_path="input/$folder"
  
  # Check if the folder exists
  if [ -d "$folder_path" ]; then
    echo "----------------------------"
    echo "Processing folder: $folder_path"
    
    echo "Running cargo command on $folder_path"

    cat "$folder_path/raw.json" | cargo run index -i "$folder_path/index-$folder"

    # Check if the cargo command was successful
    if [ $? -ne 0 ]; then
      echo "Error running cargo command. Exiting."
      exit 1
    fi

    # Enter the index-$folder directory
    index_folder="$folder_path/index-$folder"
    if [ -d "$index_folder" ]; then
      # Create zip archive with all non-hidden files
      zip_file="$index_folder.zip"
      zip -r "$zip_file" "$index_folder"/*

      # Check if the zip command was successful
      if [ $? -ne 0 ]; then
        echo "Error creating zip archive. Exiting."
        exit 1
      fi

      # Copy the zip archive to /output
      cp "$zip_file" "$output_dir/"

      # Check if the copy command was successful
      if [ $? -ne 0 ]; then
        echo "Error copying zip archive to /output. Exiting."
        exit 1
      fi

    else
      echo "Index folder $index_folder does not exist."
    fi

  else
    echo "Folder $folder_path does not exist."
  fi
done
