#!/bin/bash

generate_name() {
  local base_name=$1
  local step=$2
  local length=${#base_name}
  local min_length=4
  local name_length=$((min_length + step))
  local result=""
  local block_lengths=()

  # Initialize array with block lengths of 1 for each character
  for ((i=0; i<length; i++)); do
    block_lengths[i]=1
  done

  # Calculate used length and extra characters needed
  local used_length=$length
  local extra=$((name_length - used_length))

  # Distribute extra characters: add 1 to blocks in order while extra > 0
  local idx=0
  while (( extra > 0 )); do
    block_lengths[idx]=$((block_lengths[idx] + 1))
    ((extra--))
    idx=$(((idx + 1) % length))
  done

  # Build the name from character blocks
  for (( i=0; i<length; i++ )); do
    local char="${base_name:i:1}"
    for (( r=0; r<block_lengths[i]; r++ )); do
      result+=$char
    done
  done

  echo "$result"
}