#!/bin/bash
REDIS_HOST=localhost
if [ -z "$REDIS_HOST" ]; then export SOMEVAR=hello; else export SOMEVAR=world; fi
