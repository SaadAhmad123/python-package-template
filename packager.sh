#!/bin/bash

# This script packages the code into a zip file compatible with 
# the AWS Lambda runtime. It automates the process of preparing
# a deployment package by installing production dependencies,
# copying necessary files, and creating a zip file for Lambda.


# Function to print help message
print_help() {
  echo "Usage: $0 -d <directory> [-t <temp_directory>] [-o <output_directory>] [-h]"
  echo "Options:"
  echo "  -d <directory>              Specify the directory where .py files exist."
  echo "  -t <temp_directory>         Specify the temporary directory (default: .temp)."
  echo "  -o <output_directory>       Specify the output path (relative to the script's directory)."
  echo "  -h                          Print this help message."
}

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to cleanup and delete temp directory
cleanup() {
  if [ -d "$temp_directory" ]; then
    echo "Cleaning up. Deleting temp directory '$temp_directory'."
    rm -rf "$temp_directory"
  fi
}

# Trap exit signals to ensure cleanup is performed
trap cleanup EXIT

# Set default values
temp_directory=".temp"
output_directory="deployable"
directory="src"

# Parse command line options
while getopts ":d:t:o:h" opt; do
  case $opt in
    d)
      directory="$OPTARG"
      ;;
    t)
      temp_directory="$OPTARG"
      ;;
    o)
      output_directory="$OPTARG"
      ;;
    h)
      print_help
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      print_help
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      print_help
      exit 1
      ;;
  esac
done

# Check if 'package.json' exists in the current directory
if [ ! -f "requirments.txt" ]; then
  echo "Error: 'requirments.txt' not found in the current directory."
  exit 1
fi

# Check if help option is provided
if [ -z "$directory" ]; then
  echo "Error: Missing required options."
  print_help
  exit 1
fi

# Check if the package manager command exists
if command_exists "python3"; then
  echo "Package manager 'python3' found."
else
  echo "Error: Package manager 'python3' not found."
  exit 1
fi

# Check if the directory exists
if [ -d "$directory" ]; then
  echo "Directory '$directory' found."
else
  echo "Error: Directory '$directory' not found."
  exit 1
fi

# Check if the temp directory exists, delete and create a new one
if [ -d "$temp_directory" ]; then
  echo "Deleting existing temp directory '$temp_directory'."
  rm -rf "$temp_directory"
fi

# Check if the output directory exists, delete and then create a new one
if [ -d "$output_directory" ]; then
  echo "Deleting existing output directory '$output_directory'."
  rm -rf "$output_directory"
fi

# If all checks pass, you can proceed with the rest of your script here
echo "All checks passed. Continue with the script logic."

echo "Creating temp directory '$temp_directory'."
mkdir -p "$temp_directory"

python3 -m pip install --target "./$temp_directory" -r requirments.txt
cp -r "$directory"/* "$temp_directory"

# Check if the output directory exists, create if not
if [ ! -d "$output_directory" ]; then
  mkdir -p "$output_directory"
fi

# Create a zip file of the content of the temporary directory
cd $temp_directory
zip -r "../$output_directory/lambda.zip" .
cd ..

echo "Lambda deployment package created and stored at '$output_directory/lambda.zip'."





# temp_directory=".temp"

# echo "Creating temp directory '$temp_directory'."
# mkdir -p "$temp_directory"

# pip install --target "./$temp_directory" -r requirments.txt
# cp -r ./src/* "$temp_directory"

