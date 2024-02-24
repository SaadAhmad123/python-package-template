#!/bin/bash

# Check if the .venv is activated by checking the VIRTUAL_ENV environment variable
if [[ "$VIRTUAL_ENV" != "" ]]
then
  # If .venv is activated, proceed with the script
  echo "Virtual environment is activated."

  pip install boto3 uvicorn==0.23.2
  cd src
  uvicorn main:app --reload 
  cd ..
  pip uninstall -y boto3 botocore uvicorn
else
  # If .venv is not activated, exit the script with a message
  echo "Virtual environment is not activated. Please activate the .venv before running this script."
  exit 1
fi