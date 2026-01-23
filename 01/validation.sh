#!/bin/bash

function check_param() {
  # Check number of parameters
  if [ "$#" -ne 6 ]
  then
      echo "Must be 6 parameters"
      exit 1
  fi

  # Check if directory exists
  if [ ! -d "$directory_path" ]
  then
      echo "Directory doesn't exist!"
      exit 1
  fi

  # Check if numeric values are provided
  if [[ ! "$folders_counter" =~ ^-?[0-9]+$ ]] || [[ ! "$files_counter" =~ ^-?[0-9]+$ ]]
  then
      echo "The number of nested directories and the number of files must be specified as integers!"
      exit 1
  fi

  # Check name length constraints: folder names <= 7 chars, file names <= 7 chars
  if [ "$folders_name_len" -gt 7 ] || [ "$files_name_len" -gt 7 ]
  then echo "Files name and folders name must be not more than 7 letters"
      exit 1
  fi
  
  # Check file extension length <= 3 chars
  if [ "$files_extension_len" -gt 3 ]
  then echo "Files extention must be not more than 3 letters"
      exit 1
  fi

  # Check if only English letters are used
  if [[ ! "$folders_name" =~ ^[A-Za-z]+$ ]] || [[ ! "$files_name" =~ ^[A-Za-z]+$ ]]
  then
      echo "Use only english letters"
      exit 1
  fi

  # Validate file size format (e.g., 3Kb) and range
  if [[ "$file_size_param" =~ ^([0-9][0-9]?)[Kk][Bb]$ ]]; then
    file_size="${BASH_REMATCH[1]}"
    if (( file_size > 100 )); then
      echo "File size must be not more than 100Kb"
      exit 1
    elif (( file_size == 0 )); then
      echo "File size cannot be 0Kb"
      exit 1
    fi
  else
    echo "File size parameter must be in format like 3Kb"
    exit 1
  fi
  
  # Check that parameters 2, 3 and 6 are not zero/empty
  if [ "$2" -eq 0 ] || [ -z "$3" ]; then
    echo "Invalid parameter values"
    exit 1
  fi
}

check_free_space() {
  # Check if there's less than 1GB free space
  if [ $(df -B 1M / | tail -n 1 | awk '{print $4}') -lt 1000 ]; then
    echo -e "\033[31mLess than 1 GB free space left on disk!\033[0m"
    exit 1
  fi
}