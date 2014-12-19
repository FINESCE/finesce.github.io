#!/bin/bash

if [ "$1" == "" ]
then
	echo "Usage: $(basename $0) HTTP_COOKIE"
	echo " "
	echo "Obtain the HTTP_COOKIE from the browser after logging in to https://rm.finesce.tssg.org/redmine/"
	echo "and it is usually of the form _redmine_default=A7hB....4461; path=/redmine; HttpOnly"
	
	exit 1
fi

HTTP_COOKIE="$1"
INDEX_PAGE="https://rm.finesce.tssg.org/redmine/projects/finesce-domain-specific-enablers/wiki"
OUTPUT_FILE="/tmp/redmine_dse_index.html"

curl -s -k -H "Cookie:$HTTP_COOKIE" "$INDEX_PAGE" > $OUTPUT_FILE

echo "Saved the index to $OUTPUT_FILE"
