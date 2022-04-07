resource "aws_dynamodb_table" "demo_table" {
  name             = "vanity-numbers-table"
  read_capacity    = 5
  write_capacity   = 5
  hash_key         = "id"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "id"
    type = "S"
  }
}
