#!/bin/bash

# List of language directories from the given list, sorted alphabetically
language_folders=(
  "af" "amh" "ar" "bem" "ben" "ceb" "cre" "cs" "de" "emk" "en" "es" "ewe" "fa" "fin" "fon" 
  "fr" "hi" "hr" "hu" "id" "it" "ja" "kde" "khm" "kng" "ko" "kya" "lit" "ln" "loz" "lua" 
  "lug" "lv" "lve" "mg" "ml" "mr" "mya" "ne" "nde" "nl" "nn" "nso" "nya" "or" "orm" "osh" 
  "pa" "pl" "pt" "ro" "ru" "run" "rw" "slo" "sna" "sr" "ssw" "st" "sv" "sw" "ta" "te" "teo" 
  "tl" "tng" "tsn" "tso" "tum" "tur" "twi" "ua" "ur" "ven" "vi" "yor" "zh" "zho" "zul" "xho")

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
