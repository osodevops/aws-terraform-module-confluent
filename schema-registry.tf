module "schema-registry" {
  source = "./modules/aws-instance"

  for_each           = var.project
  name               = "schema-registry"
  instance_count     = each.value.broker_instances_per_subnet * length(module.vpc[each.key].private_subnets)
  instance_type      = each.value.instance_type
  subnet_ids         = module.vpc[each.key].public_subnets[*]
  security_group_ids = [
    module.kafka_security_group[each.key].security_group_id,
    module.ssh_security_group[each.key].security_group_id,
    module.internal_comms_security_group[each.key].security_group_id
  ]
  key_pair           = aws_key_pair.kp.key_name
  data_disk_size = 0

  project_name = each.key
  environment  = each.value.environment
  internal_dns_zone_id = module.zones.route53_zone_zone_id["confluent.internal"]
  efs_file_system_id = aws_efs_file_system.cp-ansible.id

}
