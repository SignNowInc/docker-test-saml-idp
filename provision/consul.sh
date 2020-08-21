#!/usr/bin/env bash

for i in `ls /app/consul-template`
do
 	/usr/local/bin/go-replace \
		-s 'SERVICE_NAME'       -r ${SERVICE_NAME} \
		-s 'SERVICE_KV_PATH'    -r ${SERVICE_KV_PATH} \
		/app/consul-template/$i
done