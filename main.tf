# Create a key pair for SSH access
resource "aws_key_pair" "instance_key_pair" {
  key_name   = "${var.instance_name_short}-key-pair"
  public_key = file(var.public_key_path)
}

output "info" {
  value =  "The instance will be deployed to ${var.dns_record_name}.${var.domain_name}" 
}

# Launch the EC2 instance
resource "aws_instance" "ai_ec2_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.instance_subnet.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  key_name               = aws_key_pair.instance_key_pair.key_name
  # user_data              = file("./users.yaml")

  tags = {
    Name = "${var.instance_name}-instance"
  }

  # Optional: Add a root volume with more storage if needed
  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp2"
  }

  # Upload the provision file
  # WARNING: privisioning via shell scripts is strongly discouraged.
  # I don't care. I like shell scripts
  provisioner "file" {
    content      = templatefile(
      "./provision.template.sh",
      {
        full_domain    = "${var.dns_record_name}.${var.domain_name}",
        ollama_api_key = var.ollama_api_key,
        model          = var.ai_model
      }
    )
    destination = "/tmp/provision.sh"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }

  # Execute the provisioning script
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision.sh",
      "/tmp/provision.sh"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
}

# Output the public IP of the instance
output "instance_public_ip" {
  value = aws_instance.ai_ec2_instance.public_ip
}
