
resource "aws_acm_certificate" "ctt_proj_dev_acm" {
    domain_name       = var.domain_name
    subject_alternative_names = ["www.${var.domain_name}"]
    validation_method = "DNS"

    tags = merge(var.common_tags, {
    Name = "${var.naming_prefix}-ACM"
  })

    lifecycle {
        create_before_destroy = false
    }
}

resource "aws_route53_record" "validation" {
    for_each = {
        for dvo in aws_acm_certificate.ctt_proj_dev_acm.domain_validation_options : dvo.domain_name => {
            name   = dvo.resource_record_name
            record = dvo.resource_record_value
            type   = dvo.resource_record_type
        }
    }
    zone_id = var.hosted_zone_id
    name    = each.value.name
    type    = each.value.type
    records = [each.value.record]
    ttl     = 60
}