resource "aws_dynamodb_table" "app" {
  name         = "terraform-emulator"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  # DescribeTable reports an unset on-demand maximum as -1, and the provider
  # would otherwise try to clear it on every plan.
  lifecycle {
    ignore_changes = [on_demand_throughput]
  }
}
