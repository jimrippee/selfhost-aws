#!/bin/bash

# Optional: Set your profile and region
PROFILE="default"
REGION="us-west-1"

# Step 1: List custom AMIs owned by you
echo "Fetching AMIs owned by your account..."
aws ec2 describe-images \
  --owners self \
  --profile "$PROFILE" \
  --region "$REGION" \
  --query 'Images[*].{ID:ImageId,Name:Name}' \
  --output table

# Step 2: Ask for AMI ID to delete
read -p "Enter the AMI ID you want to delete (e.g., ami-0123456789abcdef0): " AMI_ID

# Step 3: Confirm deletion
read -p "Are you sure you want to delete AMI $AMI_ID? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
  echo "Cancelled."
  exit 1
fi

# Step 4: Deregister the AMI
echo "Deregistering AMI..."
aws ec2 deregister-image \
  --image-id "$AMI_ID" \
  --profile "$PROFILE" \
  --region "$REGION"

# Step 5: Find and delete associated snapshots
echo "Looking for associated snapshots..."
SNAPSHOTS=$(aws ec2 describe-images \
  --image-ids "$AMI_ID" \
  --profile "$PROFILE" \
  --region "$REGION" \
  --query 'Images[*].BlockDeviceMappings[*].Ebs.SnapshotId' \
  --output text)

for SNAP_ID in $SNAPSHOTS; do
  read -p "Delete snapshot $SNAP_ID? (yes/no): " DELETE_SNAP
  if [[ "$DELETE_SNAP" == "yes" ]]; then
    aws ec2 delete-snapshot \
      --snapshot-id "$SNAP_ID" \
      --profile "$PROFILE" \
      --region "$REGION"
    echo "Deleted snapshot $SNAP_ID"
  else
    echo "Skipped snapshot $SNAP_ID"
  fi
done

echo "Cleanup complete."
