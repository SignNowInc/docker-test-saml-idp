#!/usr/bin/env bash

bash /app/provision/consul.sh

consul-template -log-level info -config "/app/consul/consul-template.hcl"
