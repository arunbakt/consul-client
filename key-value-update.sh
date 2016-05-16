#!/bin/bash
while read array; do
 [[ -n $array ]] && echo $array 
done

