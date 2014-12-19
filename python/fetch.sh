#!/bin/bash

INDEX_PAGE="https://rm.finesce.tssg.org/redmine/projects/finesce-domain-specific-enablers/wiki"
OUTPUT_FILE="/tmp/redmine_dse_index.html"

if [ "$1" == "" ]
then
	echo "Usage: $(basename $0) HTTP_COOKIE [ URL [ OUTPUT_PATH ] ]"
	echo " "
	echo "Obtain the HTTP_COOKIE from the browser after logging in to https://rm.finesce.tssg.org/redmine/"
	echo "and it is usually of the form _redmine_default=A7hB....4461; path=/redmine; HttpOnly"
	echo " "
	echo "URL: the URL of the file to retrieve. If omitted, the script retrieves "
	echo "     the index table at $INDEX_PAGE"
	echo "OUTPUT_PATH: the path where the script saves the page. The default "
	echo "     path is $OUTPUT_FILE"
	
	exit 1
fi

HTTP_COOKIE="$1"
if [ "$2" != "" ]
then
	INDEX_PAGE="$2"
fi

if [ "$3" != "" ]
then
	OUTPUT_FILE="$3"
fi

curl -s -k -H "Cookie:$HTTP_COOKIE" "$INDEX_PAGE" > $OUTPUT_FILE

echo "Saved the index to $OUTPUT_FILE"
