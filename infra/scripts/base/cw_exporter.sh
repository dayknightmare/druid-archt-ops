#!/bin/bash
INSTANCE_ID=$(ec2metadata --instance-id)
$DRUID_NODE_TYPE=$1

aws cloudwatch put-metric-data --region sa-east-1 --namespace="ECS" --metric-name "CPULoad" --dimensions InstanceId=${INSTANCE_ID},DruidCluterType=${DRUID_NODE_TYPE} --value $(cat /proc/loadavg | awk '{print $1}')
aws cloudwatch put-metric-data --region sa-east-1 --namespace="ECS" --metric-name "CPULoad" --dimensions DruidCluterType=${DRUID_NODE_TYPE} --value $(cat /proc/loadavg | awk '{print $1}')

aws cloudwatch --region sa-east-1 put-metric-data --namespace="ECS" --metric-name "MemoryUtilization" --unit=Percent --dimensions InstanceId=${INSTANCE_ID},DruidCluterType=${DRUID_NODE_TYPE} --value $(free | grep Mem | awk '{print $3/$2 * 100.0}')
aws cloudwatch --region sa-east-1 put-metric-data --namespace="ECS" --metric-name "MemoryUtilization" --unit=Percent --dimensions DruidCluterType=${DRUID_NODE_TYPE} --value $(free | grep Mem | awk '{print $3/$2 * 100.0}')

aws cloudwatch --region sa-east-1 put-metric-data --namespace="ECS" --metric-name "StorageLeft" --unit=Percent --dimensions InstanceId=${INSTANCE_ID},DruidCluterType=${DRUID_NODE_TYPE} --value $(df | grep -e '^/dev/root'  | awk '{printf 100-($3*100)/$2}')
aws cloudwatch --region sa-east-1 put-metric-data --namespace="ECS" --metric-name "StorageLeft" --unit=Percent --dimensions DruidCluterType=${DRUID_NODE_TYPE} --value $(df | grep -e '^/dev/root'  | awk '{printf 100-($3*100)/$2}')

aws cloudwatch --region sa-east-1 put-metric-data --namespace="ECS" --metric-name "CPUUsage" --unit=Percent --dimensions InstanceId=${INSTANCE_ID},DruidCluterType=${DRUID_NODE_TYPE} --value $(vmstat 1 2|tail -1|awk '{print 100-$15}')
aws cloudwatch --region sa-east-1 put-metric-data --namespace="ECS" --metric-name "CPUUsage" --unit=Percent --dimensions DruidCluterType=${DRUID_NODE_TYPE} --value $(vmstat 1 2|tail -1|awk '{print 100-$15}')
