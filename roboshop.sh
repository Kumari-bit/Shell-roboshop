#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-091d30e70a2b591df"
ZONE_ID="Z089235936D5DMGV67BYD"
DOMAIN_NAME="daws85s.cyou"
INSTANCES=("mongodb" "mysql" "redis" "rabbitMQ" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")

for instance in ${INSTANCES[@]}
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-091d30e70a2b591df --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text)      
    if [ $instance != "frontend" ]
    then 
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
    fi
    echo "$instance IP address is: $IP"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Creating a record set for cognito endpoint"
        ,"Changes": [{
         "Action"              : "CREATE"
        ,"ResourceRecordSet"  : {
         "Name"                 : "'$instance'.'$DOMAIN_NAME'"
         ,"Type"                : "A"  
         ,"TTL"                 : 1
         ,"ResourceRecords"     : [{
            "Value"             : "'$IP'"
        }]
      }
    }]
  }'
done