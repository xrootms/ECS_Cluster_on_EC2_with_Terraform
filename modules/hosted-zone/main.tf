#Fetching information for the manually created hosted zone "techsaif.qzz.io" using the data block.
data "aws_route53_zone" "ctt_proj_dev_techsaif_qzz_io" {
    name         = "techsaif.qzz.io"
    private_zone = false
}

# Root domain
# Need to "create record set" to connect R53 service to lb
resource "aws_route53_record" "lb_record_root" {
    zone_id = data.aws_route53_zone.ctt_proj_dev_techsaif_qzz_io.zone_id
    name    = var.domain_name
    type    = "A"

    alias {
        name                   = var.aws_lb_dns_name
        zone_id                = var.aws_lb_zone_id
        evaluate_target_health = true
    }
}

# WWW domain
resource "aws_route53_record" "lb_record_www" {
    zone_id = data.aws_route53_zone.ctt_proj_dev_techsaif_qzz_io.zone_id
    name    = "www.${var.domain_name}"
    type    = "A"

    alias {
        name                   = var.aws_lb_dns_name
        zone_id                = var.aws_lb_zone_id
        evaluate_target_health = true
    }
}
