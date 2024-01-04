#!/usr/bin/env bash
set -eou pipefail

REGION="us-east-1"
ACTION="enable"

if [ $# -gt 0 ] && [[ -n $1 ]]; then
  if [[ "$1" == "enable" ]]; then
    ACTION="$1"
  elif [[ "$1" == "disable" ]]; then
    ACTION="$1"
  else
    echo "Unknown action $1, must be one of enable | disable"
    exit 1
  fi
fi

if [ $# -gt 1 ] && [[ -n $2 ]]; then
  REGION="$2"
fi

summon docker run --rm --env-file @SUMMONENVFILE \
  amazon/aws-cli ec2 --region "$REGION" $ACTION-ebs-encryption-by-default
