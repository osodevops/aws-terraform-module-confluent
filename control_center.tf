module "control-center" {
  source = "./modules/aws-instance"

  for_each = var.project
  name = "control-center"
  instance_count     = each.value.broker_instances_per_subnet * length(module.vpc[each.key].private_subnets)
  instance_type      = each.value.instance_type
  subnet_ids         = module.vpc[each.key].private_subnets[*]
  security_group_ids = [module.app_security_group[each.key].this_security_group_id]

  data_disk_size = 0

  project_name = each.key
  environment  = each.value.environment
}
