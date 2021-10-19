#!/bin/bash
aws ec2 describe-instances --filters "Name=tag:Name,Values=broker-0"
aws ec2 describe-instances --filters "Name=tag:Name,Values=Broker-0"


aws ec2 describe-instances --filter "Name=tag:Name,Values=broker-0" --filter "Name=State[Name],Values=Terminated" --query "Reservations[*].Instances[*].[PublicIpAddress]" --output text


--filters Name=instance-type,Values=m5.large