#!/bin/bash
aws s3api create-bucket --bucket aws-oso-confluent --acl private --region eu-west-2 --create-bucket-configuration LocationConstraint=eu-west-2
aws dynamodb create-table --table-name aws-oso-confluent-terraform-locks

