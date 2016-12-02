#!/bin/bash

ZATO_BIN=/opt/zato/*.*/bin/zato

mkdir -p /opt/zato/env/qs
rm -rf /opt/zato/env/qs && mkdir -p /opt/zato/env/qs

if [ -z "$REDIS_HOST" ]; then 
   sudo service redis-server start
   REDIS_HOST=localhost
   echo "Redis Host: ${REDIS_HOST}";
fi

cd /opt/zato/env/qs
$ZATO_BIN quickstart create . sqlite $REDIS_HOST 6379 --verbose --kvdb_password "" --cluster_name "servicebus-stack" --servers 1
$ZATO_BIN from-config /opt/zato/update_password.config
