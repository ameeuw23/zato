#!/bin/bash

ZATO_BIN=/opt/zato/*.*/bin/zato

mkdir -p /opt/zato/env/qs
rm -rf /opt/zato/env/qs && mkdir -p /opt/zato/env/qs

cd /opt/zato/env/qs
$ZATO_BIN quickstart create . sqlite $REDIS_1_ENV_DOCKERCLOUD_CONTAINER_HOSTNAME 6379 --verbose --kvdb_password "" --cluster_name "servicebus-stack" --servers 1
$ZATO_BIN from-config /opt/zato/update_password.config
