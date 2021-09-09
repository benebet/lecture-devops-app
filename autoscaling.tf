# define autoscaling group
resource "aws_autoscaling_group" "custom-autoscaling-group" {
  name = "custom-autoscaling-group"
  vpc_zone_identifier = [aws_subnet.customvpc-public-1.id,aws_subnet.customvpc-public-2.id]
  launch_configuration = aws_launch_configuration.custom-launch-config.name
  min_size = 2
  max_size = 3 # Cant go higher than 3, will cause permission denied error with aws for autoscaling group (probably due to educate account restrictions)
  health_check_grace_period = 100
  health_check_type = "EC2"
  load_balancers = [aws_elb.custom-elb.name]
  force_delete = true
  tag {
    key = "Name"
    value = "TODO_APP_INSTANCE"
    propagate_at_launch = true
  }
}

# define autoscaling configuration policy
resource "aws_autoscaling_policy" "custom-cpu-policy" {
  name = "custom-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.custom-autoscaling-group.name
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = 1
  cooldown = 30
  policy_type = "SimpleScaling"
}

# define cloud watch monitoring
resource "aws_cloudwatch_metric_alarm" "custom-cpu-alarm" {
  alarm_name = "custom-cpu-alarm"
  alarm_description = "Alarm on CPU usage increase"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 120
  statistic = "Average"
  threshold = 20
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.custom-autoscaling-group.name
  }
  actions_enabled = true
  alarm_actions = [aws_autoscaling_policy.custom-cpu-policy.arn]
}

# define descaling policy
#resource "aws_autoscaling_policy" "custom-cpu-policy-scaledown" {
#  name = "custom-cpu-policy-scaledown"
#  autoscaling_group_name = aws_autoscaling_group.custom-autoscaling-group.name
#  adjustment_type = "ChangeInCapacity"
#  scaling_adjustment = -1
#  cooldown = 60
#  policy_type = "SimpleScaling"
#}

# define cloud watch monitoring for descaling
#resource "aws_cloudwatch_metric_alarm" "custom-cpu-alarm-scaledown" {
#  alarm_name = "custom-cpu-alarm-scaledown"
#  alarm_description = "Alarm on CPU usage decrease"
#  comparison_operator = "LessThanOrEqualToThreshold"
#  evaluation_periods = 2
#  metric_name = "CPUUtilization"
#  namespace = "AWS/EC2"
#  period = 120
#  statistic = "Average"
#  threshold = 10
#  dimensions = {
#    AutoScalingGroupName = aws_autoscaling_group.custom-autoscaling-group.name
#  }
#  actions_enabled = true
#  alarm_actions = [aws_autoscaling_policy.custom-cpu-policy-scaledown.arn]
#}
