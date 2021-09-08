resource "aws_efs_file_system" "cp-ansible" {
  creation_token = "oso-cp-ansible"
  tags = {
    Name = "oso-cp-ansible"
  }
}

resource "aws_efs_access_point" "cp-ansible" {
  file_system_id = aws_efs_file_system.cp-ansible.id
}

resource "aws_efs_mount_target" "alpha" {
  for_each = var.project
  file_system_id = aws_efs_file_system.cp-ansible.id
  subnet_id      = module.vpc["project-alpha"].public_subnets[0]
  security_groups = [module.internal_comms_security_group[each.key].security_group_id]
}
