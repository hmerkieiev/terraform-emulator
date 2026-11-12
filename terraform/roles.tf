resource "aws_iam_role" "service" {
  for_each = local.service_roles

  name = "terraform-emulator-${each.key}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = each.value }
      Action    = "sts:AssumeRole"
    }]
  })
}
