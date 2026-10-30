output "cluster_name" {
  value = module.eks.cluster_name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "mongo_vm_public_ip" {
  value = aws_instance.mongo_vm.public_ip
}

output "mongo_vm_private_ip" {
  value = aws_instance.mongo_vm.private_ip
}

output "backup_bucket" {
  value = aws_s3_bucket.backup.bucket
}
