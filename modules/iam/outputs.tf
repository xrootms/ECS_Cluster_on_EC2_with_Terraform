output "instance_profile_ecsInstanceRoleProfile_name" {
  value = aws_iam_instance_profile.ecsInstanceRoleProfile.name
}

output "iam_role_ecsTaskExecutionRole_arn" {
  value = aws_iam_role.ecsTaskExecutionRole.arn
}