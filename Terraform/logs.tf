resource "aws_cloudwatch_log_group" "cloudwatch-log-group" {
    name = "${var.name}-log-group"
    retention_in_days = 7
    tags = merge(
        local.tags,
        {
            Name = "${var.name}-log-group"
        }
    )
}
  
resource "aws_cloudwatch_log_stream" "cloudwatch-log-stream" {
    name = "${var.name}-log-stream"
    log_group_name = "${aws_cloudwatch_log_group.cloudwatch-log-group.name}"
}