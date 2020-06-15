#!/bin/bash

pushd $( dirname "${BASH_SOURCE[0]}" )

project_id=$(basename $(pwd))
username=$(sed 's/@.*$//g' user.txt | tr '[:upper:]._' '[:lower:]--' )

name_servers=$(gcloud dns managed-zones describe ${username}-zone --format='value(nameServers)' --project $project_id)
IFS=';' read -r -a name_servers_ra <<< "$name_servers"

zone_id=$(aws route53 list-hosted-zones | jq -r '.HostedZones | .[] | select(.Name=="k8s.pal.pivotal.io.") | .Id')

subdomain="${username}.k8s.pal.pivotal.io."

read -r -d '' record_change_request <<EOF
{
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "${subdomain}",
        "Type": "NS",
        "TTL": 300,
        "ResourceRecords": [
          { "Value": "${name_servers_ra[0]}" },
          { "Value": "${name_servers_ra[1]}" },
          { "Value": "${name_servers_ra[2]}" },
          { "Value": "${name_servers_ra[3]}" }
        ]
      }
    }
  ]
}
EOF

aws route53 change-resource-record-sets \
    --hosted-zone-id ${zone_id} \
    --change-batch "${record_change_request}" \
    --output json > /dev/null