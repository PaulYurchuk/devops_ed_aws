#!/bin/bash

USED=`free -m |  awk '/cache:/ {print $3}'`
TOTAL=`free -m |  awk '/^Mem:/ {print $2}'`
VALUE=$(echo "($USED/$TOTAL)*100" | bc -l | grep -o '[0-9]*\.[0-9]\{2\}')

/usr/bin/aws cloudwatch put-metric-data \
  --namespace DevOpsED \
  --metric-name MemoryUsed \
  --dimensions "Hostname=$(hostname)" \
  --region eu-west-1 \
  --unit Percent \
  --value $VALUE
