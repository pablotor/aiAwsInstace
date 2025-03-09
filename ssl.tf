# Once instance and DNS record are created, run certbot
resource "null_resource" "run_certbot" {
  depends_on = [aws_instance.ai_ec2_instance, aws_route53_record.instance_dns]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)
      host        = aws_instance.ai_ec2_instance.public_ip
    }

    inline = [
      # Install certbot
      "sudo dnf install -y augeas-libs",
      "sudo python3 -m venv /opt/certbot/",
      "sudo /opt/certbot/bin/pip install --upgrade pip",
      "sudo /opt/certbot/bin/pip install certbot certbot-nginx",
      "sudo ln -s /opt/certbot/bin/certbot /usr/bin/certbot",
      # Get SSL Certificate
      "sudo certbot --nginx -n -d ${var.dns_record_name}.${var.domain_name} --email ${var.email} --agree-tos --redirect --hsts",
      "sudo systemctl restart nginx",
      # Set up a cron job for automated renewal
      "echo \"0 0,12 * * * root /opt/certbot/bin/python -c 'import random; import time; time.sleep(random.random() * 3600)' && sudo certbot renew -q\" | sudo tee -a /etc/crontab > /dev/null"
    ]
  }
}