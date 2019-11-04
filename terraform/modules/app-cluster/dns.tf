resource "aws_route53_record" "ccms_provider_details" {
  zone_id = data.aws_cloudformation_stack.dns.outputs["HostedZoneId"]
  name    = "hello-world.dev.legalservices.gov.uk"
  type = "A"

  alias {
    name                   = aws_alb.main.dns_name
    zone_id                = aws_alb.main.zone_id
    evaluate_target_health = false
  }
}
