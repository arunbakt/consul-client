#!/bin/bash
service_name=$1
while read array; do
 [[ -n $array ]] && echo $array 
done

