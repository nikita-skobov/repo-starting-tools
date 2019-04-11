#!/usr/bin/env bash

username=$1
json_data=$2

echo "username: $username"
echo "json data:"
echo "$json_data"
echo ""

curl -u "$username" -H "Accept: application/vnd.github.v3+json" -X POST https://api.github.com/user/repos -d "$json_data"
