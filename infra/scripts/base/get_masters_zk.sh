IPS=$(aws ec2 describe-instances --filters 'Name=tag:Name,Values=druid-overlord*' --query 'Reservations[*].Instances[*].PrivateDnsName' --output text)

result=""

for ip in $IPS; do
   result="$result,$ip:2181"
done

export DRUID_IPS_ZK=${result#*,}