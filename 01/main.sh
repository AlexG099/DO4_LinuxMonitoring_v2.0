#!/usr/bin/env bash

set -euo pipefail

source ./validation.sh
source ./name_generator.sh

directory_path=$1
folders_counter=$2
folders_name=$3
files_counter=$4
files_name="${5%%.*}"
file_size_param=$6
files_extension="${5#*.}"
script_start_date=$(date '+%d%m%y')

folders_name_len=${#folders_name}
files_name_len=${#files_name}
files_extension_len=${#files_extension}

trash_folders_name="$folders_name"
trash_files_name="$files_name"
trash_files_extension_name="$files_extension"
finish_file_name=""

last_folder_char=""
last_files_char=""

log_file="$PWD/file_logs.txt"
: > "$log_file" || { echo "Cannot write to log file $log_file"; exit 1; }
echo "Logging to $log_file" >&2


create_trash() {
    # Change to target directory
    local base_dir="$PWD"
    cd "$directory_path" || { echo "Failed to cd into $directory_path"; exit 1; }

    for (( i=0; i<folders_counter; i++ )); do
        # Generate folder name
        trash_folders_name=$(generate_name "$folders_name" "$i")
        trash_folders_with_date="${trash_folders_name}_${script_start_date}"
        mkdir -p "$trash_folders_with_date"
        
        local folder_full_path="${base_dir}/${trash_folders_with_date}"

      # Log folder creation
      {
        echo "PATH: $folder_full_path"
        echo "DATE: $(date '+%H:%M:%S %d-%m-%Y %Z')"
        echo "TYPE: directory"
        echo ""
      } >> "$log_file"

        cd "$trash_folders_with_date"
        # Create files in the folder
        for (( y=0; y<files_counter; y++ )); do
            # Generate file name
            check_free_space
            trash_files_name=$(generate_name "$files_name" "$y")
            finish_file_name="${trash_files_name}_${script_start_date}.${files_extension}"

            # Create file with specified size
            dd if=/dev/zero of="$finish_file_name" bs=1K count="$file_size" status=none
            local abs_path="${folder_full_path}/${finish_file_name}"
            # Log file creation
            {
              echo "PATH: $abs_path"
              echo "DATE: $(date '+%H:%M:%S %d-%m-%Y %Z')"
              echo "TYPE: file"
              echo "SIZE: $file_size Kb"
              echo ""
            } >> "$log_file"
        done
        cd ./..
    done
}


check_param "$@"
create_trash