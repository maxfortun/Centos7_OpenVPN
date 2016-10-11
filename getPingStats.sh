#!/bin/bash

hosts=$*

if [ -z "$hosts" ]; then
	hosts=$(ls | cut -d. -f1-3|sort -V -fu) 
fi

for host in $hosts; do
	ping -q -i .2 -c 4 $host | tail -1 | cut -d/ -f5 | xargs echo $host 
done
