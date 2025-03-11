#!/bin/bash

# Variables
BUCKET_NAME="demo-app-bucket"

# Create the bucket
gsutil mb gs://$BUCKET_NAME/

# Upload the index.html file to the bucket
gsutil cp ../../../cicd/index.html gs://$BUCKET_NAME/