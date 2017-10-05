#!/bin/bash -ex

LOGS="/root/post-install.$(date -I)"
exec > $LOGS 2>&1

RUN_LIST="instance_bootstrap.sh mem.sh"

for script in $RUN_LIST; do
  aws s3 cp s3://devops_ed_scripts/$script /root/
  bash /root/$script
done

echo "*/1 * * * * root /root/mem.sh" > /etc/cron.d/mem_used
