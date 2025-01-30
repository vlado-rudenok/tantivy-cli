#!/bin/bash

# List of language directories from the given list, sorted alphabetically
language_folders=("af" "amh" "ceb" "cs" "de" "en" "es" "fr" "hi" "hu" "id" "it" "ja" "khm" "ko" "lug" "mya" "nl" "or" "pl" "pt" "ro" "ru" "run" "rw" "sr" "ssw" "sw" "ta" "te" "teo" "tl" "yor" "zh" "zul")

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

    cat "$folder_path/raw.json" | tantivy index -i "$folder_path/index-$folder"

    # Check if the cargo command was successful
    if [ $? -ne 0 ]; then
      echo "Error running cargo command. Exiting."
      exit 1
    fi

    # Enter the index-$folder directory
    index_folder="$folder_path/index-$folder"
    if [ -d "$index_folder" ]; then
      # Create zip archive with all non-hidden files, stripping out directory paths
      zip_file="$output_dir/index-$folder.zip"
      zip -j "$zip_file" "$index_folder"/*

      # Check if the zip command was successful
      if [ $? -ne 0 ]; then
        echo "Error creating zip archive. Exiting."
        exit 1
      fi

    else
      echo "Index folder $index_folder does not exist."
    fi

  else
    echo "Folder $folder_path does not exist."
  fi
done
