#!/bin/bash

# Script to create or update an ECS service and task definition

usage() {
  echo "Usage: $0 -c <ECS_CLUSTER> -s <SERVICE_NAME> -f <SERVICE_DEFINITION_FILE> -t <TASK_DEFINITION_FILE> [-r <AWS_REGION>] [-h HELP]"
  echo " -c: ECS cluster name (mandatory)"
  echo " -s: ECS service name (mandatory)"
  echo " -f: Service definition file (mandatory)"
  echo " -t: Task definition file (mandatory)"
  echo " -r: AWS region (optional, defaults to 'eu-west-1')"
  echo " -h: Show this help message"
}

ECS_CLUSTER=""
SERVICE_NAME=""
SERVICE_DEFINITION_FILE=""
TASK_DEFINITION_FILE=""
AWS_REGION="eu-west-1"

while getopts "c:s:f:t:r:h" opt; do
  case $opt in
    c)
      ECS_CLUSTER="$OPTARG"
      ;;
    s)
      SERVICE_NAME="$OPTARG"
      ;;
    f)
      SERVICE_DEFINITION_FILE="$OPTARG"
      ;;
    t)
      TASK_DEFINITION_FILE="$OPTARG"
      ;;
    r)
      AWS_REGION="$OPTARG"
      ;;
    h)
      usage
      exit 0
      ;;
    \?)
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$ECS_CLUSTER" || -z "$SERVICE_NAME" || -z "$SERVICE_DEFINITION_FILE" || -z "$TASK_DEFINITION_FILE" ]]; then
  usage
  exit 1
fi

SERVICE_EXISTS=$(aws ecs describe-services --services "$SERVICE_NAME" --cluster "$ECS_CLUSTER" --region "$AWS_REGION" | jq -r '.services | length')

if [[ "$SERVICE_EXISTS" -eq "1" ]]; then
  DESIRED_COUNT=$(aws ecs describe-services --services "$SERVICE_NAME" --cluster "$ECS_CLUSTER" --region "$AWS_REGION" | jq -r '.services[0].desiredCount')
  aws ecs update-service --cluster "$ECS_CLUSTER" --service "$SERVICE_NAME" --region "$AWS_REGION" --desired-count "$DESIRED_COUNT"
else
  aws ecs create-service --launch-type FARGATE --service-name "$SERVICE" --cli-input-json file://"$SERVICE_DEFINITION_FILE" --force-new-deployment --region "$AWS_REGION"
fi

exit 0
