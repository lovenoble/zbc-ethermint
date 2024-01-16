provider "aws" {
  region = "${var.region}"
}

# Initialize a new VPC
resource "aws_vpc" "validator_testnet_vpc" {
  cidr_block = "${var.cidr_vpc}"
}

# Create an Internet Gateway
resource "aws_internet_gateway" "validator_testnet_igw" {
  vpc_id = aws_vpc.validator_testnet_vpc.id
}

resource "aws_default_route_table" "testnet_vpc" {
  default_route_table_id = aws_vpc.validator_testnet_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.validator_testnet_igw.id
  }
}

resource "aws_key_pair" "machine_key" {
  key_name   = "validator-testnet-key-1"
  public_key = var.ssh_public_key
}

# Define subnet CIDR blocks
locals {
  subnet_suffix = range(10, 49)
}

# Create subnets with internal IPs
resource "aws_subnet" "internal_subnet" {
  cidr_block = "${var.cidr_subnet}"
  vpc_id = aws_vpc.validator_testnet_vpc.id
  availability_zone = "${var.az}"
}

resource "aws_subnet" "elb_extra_subnet" {
  cidr_block = "${var.elb_extra_subnet}"
  vpc_id = aws_vpc.validator_testnet_vpc.id
  availability_zone = "${var.elb_extra_az}"
}

resource "aws_security_group" "alb_sg" {
  name = "alb_sg"
  description = "Allow HTTP/HTTPS traffic to elb"
  vpc_id = aws_vpc.validator_testnet_vpc.id
}

resource "aws_security_group_rule" "alb_sg_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "alb_sg_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "alb_sg_egress_rpc" {
  type              = "egress"
  from_port         = 8545
  to_port           = 8545
  protocol          = "tcp"
  cidr_blocks       = ["${var.cidr_subnet}"]
  security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "alb_sg_egress_block_explorer" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["${var.cidr_subnet}"]
  security_group_id = aws_security_group.alb_sg.id
}

# Create a Security Group for the worker nodes to allow communication between them
resource "aws_security_group" "worker_sg" {
  name = "worker_sg"
  description = "Allow worker nodes to communicate with each other"
  vpc_id = aws_vpc.validator_testnet_vpc.id
}

resource "aws_security_group_rule" "worker_sg_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["${var.cidr_vpc}"]
  security_group_id = aws_security_group.worker_sg.id
}

resource "aws_security_group_rule" "worker_sg_internet" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.worker_sg.id
}

# Create the VPN Security Group to allow inbound traffic from the internet
resource "aws_security_group" "vpn_sg" {
  name = "vpn_sg"
  description = "Allow inbound traffic from the internet to the VPN server"
  vpc_id = aws_vpc.validator_testnet_vpc.id
}

resource "aws_security_group_rule" "vpn_sg_icmp" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.vpn_sg.id
}

resource "aws_security_group_rule" "vpn_sg_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.vpn_sg.id
}

resource "aws_security_group_rule" "vpn_sg_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.vpn_sg.id
}

resource "aws_security_group_rule" "vpn_sg_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.vpn_sg.id
}

resource "aws_security_group_rule" "vpn_sg_wg" {
  type              = "ingress"
  from_port         = 51820
  to_port           = 51820
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.vpn_sg.id
}

resource "aws_security_group_rule" "vpn_sg_internet" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.vpn_sg.id
}

resource "aws_iam_instance_profile" "logs_ec2_instance_profile" {
  name = "logs-ec2-instance-profile"

  # Attach the existing IAM role to the instance profile
  role = "zbc-cloud-watch"
}

# Create the VPN server in a public subnet with public IP and Elastic IP and update its variable to use the EIP
resource "aws_instance" "validator_testnet_vpn" {
  ami = "${var.ami}"
  instance_type = "c5n.large"
  associate_public_ip_address = true
  private_ip = "10.0.0.100"
  subnet_id = aws_subnet.internal_subnet.id
  source_dest_check = false

  key_name = aws_key_pair.machine_key.id
  iam_instance_profile = aws_iam_instance_profile.logs_ec2_instance_profile.name

  security_groups = [aws_security_group.vpn_sg.id]

  # forces recreation every time if not here for some reason
  lifecycle {
    ignore_changes = [
      security_groups
    ]
  }

  user_data = <<-EOF
                #!/bin/bash
                apt-get update -y
                apt-get upgrade -y

                # nat forwarding
                sysctl -w net.ipv4.ip_forward=1
                sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf

                # ubuntu throws interactive scripts for nginx install otherwise
                sed -i "s/#\$nrconf{restart} = 'i';/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf

                # allow nginx to serve files for our private keys
                chmod 755 /home/ubuntu

                # nginx to serve sks/pks/cks keys
                apt-get install -y nginx bmon

                echo 'server {
                  listen 10.0.0.100:80 default_server;

                  root /home/ubuntu/fhevm-keys;

                  server_name _;

                  location / {
                    # First attempt to serve request as file, then
                    # as directory, then fall back to displaying a 404.
                    try_files $uri $uri/ =404;
                  }
                }' > /etc/nginx/sites-available/default

                nginx -s reload

                # create service to set up NAT rules upon every reboot
                echo '[Unit]
                Description=Set up NAT instance for internal nodes

                [Service]
                Type=oneshot
                ExecStart=/usr/sbin/nft -f /root/rules.nft
                RemainAfterExit=yes

                [Install]
                WantedBy=multi-user.target' > /etc/systemd/system/nat-instance.service

                echo 'table nat {
                  chain postrouting {
                    type nat hook postrouting priority 0;
                    ip saddr 10.0.0.0/24 oif ens5 masquerade;
                  }
                }' > /root/rules.nft

                systemctl daemon-reload
                systemctl enable nat-instance.service
                systemctl restart nat-instance.service


                EOF

  tags = {
    Name = "Validator testnet vpn-server"
  }
}

resource "aws_instance" "validator_testnet_kms" {
  ami = "${var.ami}"
  instance_type = "${var.worker_type}"
  associate_public_ip_address = false
  private_ip = "10.0.0.50"
  subnet_id = aws_subnet.internal_subnet.id

  key_name = aws_key_pair.machine_key.id
  iam_instance_profile = aws_iam_instance_profile.logs_ec2_instance_profile.name

  user_data = <<-EOF
                #!/bin/bash
                apt-get update -y
                apt-get upgrade -y

                # add route to the internet via our vpn nat instance
                echo '[Unit]
                Description=Set up NAT instance for internal nodes

                [Service]
                Type=oneshot
                ExecStart=/usr/sbin/ip route add 0.0.0.0/0 via 10.0.0.100
                RemainAfterExit=yes

                [Install]
                WantedBy=multi-user.target' > /etc/systemd/system/nat-route.service

                systemctl daemon-reload
                systemctl enable nat-route.service
                systemctl restart nat-route.service

                apt-get update -y
                apt-get upgrade -y

                apt-get install -y apt-transport-https ca-certificates curl software-properties-common
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
                apt-get update -y

                apt-get install -y docker-ce

                usermod -aG docker ubuntu

                EOF

  security_groups = [aws_security_group.worker_sg.id]

  root_block_device {
    volume_size = "${var.worker_disk_size_gb}"
  }

  # forces recreation every time if not here for some reason
  lifecycle {
    ignore_changes = [
      security_groups
    ]
  }

  tags = {
    Name = "Validator testnet KMS server"
  }
}

resource "aws_instance" "validator_testnet_workers" {
  count = var.validator_count + var.full_node_count
  ami = "${var.ami}"
  instance_type = "${var.worker_type}"
  associate_public_ip_address = false
  private_ip = "10.0.0.${local.subnet_suffix[count.index]}"
  subnet_id = aws_subnet.internal_subnet.id

  key_name = aws_key_pair.machine_key.id
  iam_instance_profile = aws_iam_instance_profile.logs_ec2_instance_profile.name

  user_data = <<-EOF
                #!/bin/bash
                # add route to the internet via our vpn nat instance
                echo '[Unit]
                Description=Set up NAT instance for internal nodes

                [Service]
                Type=oneshot
                ExecStart=/usr/sbin/ip route add 0.0.0.0/0 via 10.0.0.100
                RemainAfterExit=yes

                [Install]
                WantedBy=multi-user.target' > /etc/systemd/system/nat-route.service

                systemctl daemon-reload
                systemctl enable nat-route.service
                systemctl restart nat-route.service

                apt-get update -y
                apt-get upgrade -y

                apt-get install -y apt-transport-https ca-certificates curl software-properties-common
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
                apt-get update -y

                apt-get install -y docker-ce

                usermod -aG docker ubuntu

                EOF

  security_groups = [aws_security_group.worker_sg.id]

  root_block_device {
    volume_size = "${var.worker_disk_size_gb}"
  }

  # forces recreation every time if not here for some reason
  lifecycle {
    ignore_changes = [
      security_groups
    ]
  }

  tags = {
    Name = "Validator testnet worker server ${count.index}"
  }

  # make sure VPN/NAT node is setup before worker nodes
  depends_on = [
    aws_instance.validator_testnet_vpn
  ]
}

resource "aws_instance" "block_explorer" {
  ami = "${var.ami}"
  instance_type = "c5a.4xlarge"
  associate_public_ip_address = false
  private_ip = "10.0.0.70"
  subnet_id = aws_subnet.internal_subnet.id

  key_name = aws_key_pair.machine_key.id
  iam_instance_profile = aws_iam_instance_profile.logs_ec2_instance_profile.name

  user_data = <<-EOF
                #!/bin/bash
                # add route to the internet via our vpn nat instance
                echo '[Unit]
                Description=Set up NAT instance for internal nodes

                [Service]
                Type=oneshot
                ExecStart=/usr/sbin/ip route add 0.0.0.0/0 via 10.0.0.100
                RemainAfterExit=yes

                [Install]
                WantedBy=multi-user.target' > /etc/systemd/system/nat-route.service

                systemctl daemon-reload
                systemctl enable nat-route.service
                systemctl restart nat-route.service

                apt-get update -y
                apt-get upgrade -y

                apt-get install -y apt-transport-https ca-certificates curl software-properties-common unzip
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
                apt-get update -y

                apt-get install -y docker-ce postgresql-client

                usermod -aG docker ubuntu

                cd /home/ubuntu
                wget https://github.com/blockscout/blockscout/archive/refs/tags/v5.3.3-beta.zip
                unzip v5.3.3-beta.zip
                cd /home/ubuntu/blockscout-5.3.3-beta/docker-compose

                sed -i 's|# INDEXER_TOKEN_BALANCES_BATCH_SIZE=|INDEXER_TOKEN_BALANCES_BATCH_SIZE=0|g' envs/common-blockscout.env
                sed -i 's|Awesome chain|${var.chain_name}|g' envs/common-frontend.env
                sed -i 's|Awesome chain|${var.chain_name}|g' envs/common-blockscout.env
                sed -i 's|ETHEREUM_JSONRPC_HTTP_URL: http://host.docker.internal:8545/|ETHEREUM_JSONRPC_HTTP_URL: http://10.0.0.17:8545/|g' docker-compose.yml
                sed -i 's|ETHEREUM_JSONRPC_TRACE_URL: http://host.docker.internal:8545/|ETHEREUM_JSONRPC_TRACE_URL: http://10.0.0.17:8545/|g' docker-compose.yml
                sed -i 's|ETHEREUM_JSONRPC_WS_URL: ws://host.docker.internal:8545/|ETHEREUM_JSONRPC_WS_URL: ws://10.0.0.17:8546/|g' docker-compose.yml
                sed -i 's|NEXT_PUBLIC_API_HOST=localhost|NEXT_PUBLIC_API_HOST=${var.explorer_dns_name}|g' envs/common-frontend.env
                sed -i 's|NEXT_PUBLIC_APP_HOST=localhost|NEXT_PUBLIC_APP_HOST=${var.explorer_dns_name}|g' envs/common-frontend.env
                sed -i 's|NEXT_PUBLIC_STATS_API_HOST=http://localhost:8080|NEXT_PUBLIC_STATS_API_HOST=https://${var.explorer_dns_name}|g' envs/common-frontend.env
                sed -i 's|NEXT_PUBLIC_API_PROTOCOL=http|NEXT_PUBLIC_API_PROTOCOL=https|g' envs/common-frontend.env
                sed -i 's|NEXT_PUBLIC_APP_PROTOCOL=http|NEXT_PUBLIC_APP_PROTOCOL=https|g' envs/common-frontend.env
                sed -i 's|NEXT_PUBLIC_API_WEBSOCKET_PROTOCOL=ws|NEXT_PUBLIC_API_WEBSOCKET_PROTOCOL=wss|g' envs/common-frontend.env
                echo '${filebase64("${path.module}/block-explorer-nginx.conf")}' | base64 -d > proxy/default.conf.template

                while ! docker ps; do sleep 1; done
                docker compose up -d

                EOF

  security_groups = [aws_security_group.worker_sg.id]

  root_block_device {
    volume_size = "512"
  }

  # forces recreation every time if not here for some reason
  lifecycle {
    ignore_changes = [
      security_groups
    ]
  }

  tags = {
    Name = "Validator testnet block explorer"
  }

  # make sure VPN/NAT node is setup before worker nodes
  depends_on = [
    aws_instance.validator_testnet_vpn
  ]
}

resource "aws_lb" "rpc_alb" {
  name               = "full-node-rpc-elb"
  internal           = false
  load_balancer_type = "application"

  subnets = [aws_subnet.internal_subnet.id, aws_subnet.elb_extra_subnet.id]
  security_groups = [aws_security_group.alb_sg.id]

  tags = {
    Name = "Full Nodes RPC elb"
  }
}

resource "aws_lb_listener" "rpc_alb_http" {
  load_balancer_arn = aws_lb.rpc_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "rpc_alb_https" {
  load_balancer_arn = aws_lb.rpc_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate_validation.rpc_acm.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rpc_alb_tg.arn
  }
}

resource "aws_lb_target_group" "rpc_alb_tg" {
  vpc_id      = aws_vpc.validator_testnet_vpc.id

  name        = "rpc-lb-tg"
  target_type = "instance"
  port        = 8545
  protocol    = "HTTP"
  health_check {
    protocol = "HTTP"
    path = "/"
    port = 8545
    matcher = "200,405"
  }
}

resource "aws_lb_target_group_attachment" "rpc_alb_tg_attachment" {
  count = var.full_node_count

  target_group_arn = aws_lb_target_group.rpc_alb_tg.arn
  target_id        = aws_instance.validator_testnet_workers[var.validator_count + count.index].id
  port             = 8545
}

resource "aws_lb" "blockscout_alb" {
  name               = "blockscout-elb"
  internal           = false
  load_balancer_type = "application"

  subnets = [aws_subnet.internal_subnet.id, aws_subnet.elb_extra_subnet.id]
  security_groups = [aws_security_group.alb_sg.id]

  tags = {
    Name = "Blockscout load balancer"
  }
}

resource "aws_lb_listener" "rpc_blockscout_http" {
  load_balancer_arn = aws_lb.blockscout_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "rpc_blockscout_https" {
  load_balancer_arn = aws_lb.blockscout_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate_validation.explorer_acm.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blockscout_alb_tg.arn
  }
}

resource "aws_lb_target_group" "blockscout_alb_tg" {
  vpc_id      = aws_vpc.validator_testnet_vpc.id

  name        = "blockscout-lb-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  health_check {
    protocol = "HTTP"
    path = "/"
    port = 80
    matcher = "200"
  }
}

resource "aws_lb_target_group_attachment" "blockscout_alb_tg_attachment" {
  target_group_arn = aws_lb_target_group.blockscout_alb_tg.arn
  target_id        = aws_instance.block_explorer.id
  port             = 80
}

# Certificates for explorer + rpc
data "aws_route53_zone" "root_zone" {
  name         = "zama.ai"
  private_zone = false
}

# block explorer certificates + DNS
resource "aws_acm_certificate" "explorer_acm" {
  domain_name       = var.explorer_dns_name
  validation_method = "DNS"
}

resource "aws_route53_record" "explorer_dns_verification" {
  for_each = {
    for dvo in aws_acm_certificate.explorer_acm.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.root_zone.zone_id
}

resource "aws_route53_record" "explorer_dns_cname" {
  name            = var.explorer_dns_name
  records         = [aws_lb.blockscout_alb.dns_name]
  type            = "CNAME"

  allow_overwrite = true
  ttl             = 60
  zone_id         = data.aws_route53_zone.root_zone.zone_id
}

resource "aws_acm_certificate_validation" "explorer_acm" {
  certificate_arn         = aws_acm_certificate.explorer_acm.arn
  validation_record_fqdns = [for record in aws_route53_record.explorer_dns_verification : record.fqdn]
}


# RPC certificates + DNS
resource "aws_acm_certificate" "rpc_acm" {
  domain_name       = var.rpc_dns_name
  validation_method = "DNS"
}

resource "aws_route53_record" "rpc_dns_verification" {
  for_each = {
    for dvo in aws_acm_certificate.rpc_acm.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.root_zone.zone_id
}

resource "aws_route53_record" "rpc_dns_cname" {
  name            = var.rpc_dns_name
  records         = [aws_lb.rpc_alb.dns_name]
  type            = "CNAME"

  allow_overwrite = true
  ttl             = 60
  zone_id         = data.aws_route53_zone.root_zone.zone_id
}

resource "aws_acm_certificate_validation" "rpc_acm" {
  certificate_arn         = aws_acm_certificate.rpc_acm.arn
  validation_record_fqdns = [for record in aws_route53_record.rpc_dns_verification : record.fqdn]
}
