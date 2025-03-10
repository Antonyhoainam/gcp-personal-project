#!/bin/bash

# Variables
CLUSTER_NAME="cluster1"
REGION="us-west1"
MAX_RETRIES=60  # 30 minutes timeout with 30 seconds interval
RETRY_INTERVAL=30

# Create GKE cluster
echo "Creating GKE cluster '$CLUSTER_NAME'..."
gcloud container clusters create $CLUSTER_NAME \
    --region $REGION \
    --network demo \
    --num-nodes 2 \
    --machine-type e2-small \
    --enable-autoscaling \
    --min-nodes 1 \
    --max-nodes 3 \
    --disk-size 50 \
    --enable-ip-alias \
    --enable-network-policy \
    --cluster-ipv4-cidr 10.0.0.0/14 \
    --logging="SYSTEM,API_SERVER,WORKLOAD" \
    --monitoring="SYSTEM,API_SERVER,POD,DEPLOYMENT,STATEFULSET,STORAGE" \
    --maintenance-window-start 2025-03-11T04:00:00Z \
    --maintenance-window-end 2025-03-11T10:00:00Z \
    --maintenance-window-recurrence 'FREQ=WEEKLY;BYDAY=MO,TU,FR'

# Check if the cluster creation was successful
if [ $? -ne 0 ]; then
  echo "Failed to create GKE cluster '$CLUSTER_NAME'. Exiting."
  exit 1
fi

# Function to check cluster status
check_cluster_status() {
  local status=$(gcloud container clusters describe $CLUSTER_NAME --region $REGION --format="value(status)")
  echo "Cluster status: $status"
  if [ "$status" == "RUNNING" ]; then
    return 0
  else
    return 1
  fi
}

# Main script
echo "Checking if GKE cluster '$CLUSTER_NAME' is ready..."

for ((i=1; i<=MAX_RETRIES; i++)); do
  if check_cluster_status; then
    echo "Cluster '$CLUSTER_NAME' is ready."
    exit 0
  else
    echo "Cluster '$CLUSTER_NAME' is not ready yet. Retrying in $RETRY_INTERVAL seconds... ($i/$MAX_RETRIES)"
    sleep $RETRY_INTERVAL
  fi
done

echo "Cluster '$CLUSTER_NAME' is not ready after 30 minutes timeout."
exit 1