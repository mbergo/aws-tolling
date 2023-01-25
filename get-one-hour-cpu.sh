#!/bin/bash

# Get a list of all EC2 instances
instances=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].InstanceId' --output text)

# Loop through each instance
for instance in $instances
do
    # Get the average CPU usage for the last hour
    avg_usage=$(aws cloudwatch get-metric-data --metric-data-queries "[{\"Id\":\"m1\",\"MetricStat\":{\"Metric\":{\"Namespace\":\"AWS/EC2\",\"MetricName\":\"CPUUtilization\",\"Dimensions\":[{\"Name\":\"InstanceId\",\"Value\":\"$instance\"}]},\"Period\":3600,\"Stat\":\"Maximum\"},\"ReturnData\":true}]" --start-time $(date -u +"%Y-%m-%dT%H:%M:%SZ" --date "1 hour ago") --end-time $(date -u +"%Y-%m-%dT%H:%M:%SZ") --output text | grep "VALUES")

  
    # Get the name of the instance
    name=$(aws ec2 describe-instances --instance-ids $instance --query 'Reservations[*].Instances[*].Tags[?Key==`Name`].Value' --output text)

    # Print the data in the format "<machine-name> : <avg%> rounded down to 3 digits, showing the average usage between 0% and 100% of CPU
    echo "During the last one hour, ====> $name utilized ====> $(echo $avg_usage% | sed 's/\ //g') OF CPU on MAXIMUM, between 0% and 100%" | sed 's/VALUES//'
done

