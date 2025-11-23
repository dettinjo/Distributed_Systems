terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = { Name = "${var.region_name}-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.this.id
  cidr_block = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone = "${var.region_name}a"
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.this.id
  cidr_block = var.private_subnet_cidr
  availability_zone = "${var.region_name}b"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "web" {
  name   = "${var.region_name}-web"
  vpc_id = aws_vpc.this.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "public" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = var.key_name

  user_data = <<EOF
#!/bin/bash
apt-get update
apt-get install -y python3-pip
pip3 install flask
cat <<PYEOF > /home/ubuntu/app.py
from flask import Flask, request, render_template_string
app = Flask(__name__)
FEEDBACKS = []
VM_NAME = "${var.vm_name_public}"
@app.route("/", methods=['GET', 'POST'])
def home():
  if request.method == "POST":
    fb = request.form.get("feedback")
    if fb: FEEDBACKS.append(fb)
  return render_template_string('''
  <h2>Feedback Form</h2>
  <p style="font-weight:bold;color:blue;">You are visiting: <span style="font-size:larger;">{{vm_name}}</span></p>
  <form method="post">
    <input name="feedback" placeholder="Write your feedback" required>
    <button type="submit">Send</button>
  </form>
  <h3>Submitted feedback:</h3>
  <ul>{% for fb in feedbacks %}<li>{{fb}}</li>{% endfor %}</ul>''', feedbacks=FEEDBACKS, vm_name=VM_NAME)
app.run(host="0.0.0.0", port=80)
PYEOF
nohup python3 /home/ubuntu/app.py &
EOF
  tags = { Name = "${var.vm_name_public}" }
}

resource "aws_instance" "private" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  key_name                    = var.key_name
  associate_public_ip_address = false

  user_data = <<EOF
#!/bin/bash
apt-get update
apt-get install -y python3-pip
pip3 install flask
cat <<PYEOF > /home/ubuntu/app.py
from flask import Flask, request, render_template_string
app = Flask(__name__)
FEEDBACKS = []
VM_NAME = "${var.vm_name_private}"
@app.route("/", methods=['GET', 'POST'])
def home():
  if request.method == "POST":
    fb = request.form.get("feedback")
    if fb: FEEDBACKS.append(fb)
  return render_template_string('''
  <h2>Feedback Form</h2>
  <p style="font-weight:bold;color:green;">You are visiting: <span style="font-size:larger;">{{vm_name}}</span></p>
  <form method="post">
    <input name="feedback" placeholder="Write your feedback" required>
    <button type="submit">Send</button>
  </form>
  <h3>Submitted feedback:</h3>
  <ul>{% for fb in feedbacks %}<li>{{fb}}</li>{% endfor %}</ul>''', feedbacks=FEEDBACKS, vm_name=VM_NAME)
app.run(host="0.0.0.0", port=80)
PYEOF
nohup python3 /home/ubuntu/app.py &
EOF
  tags = { Name = "${var.vm_name_private}" }
}

# --- Add Elastic IP to the private instance for transformation step ---
# resource "aws_eip" "private" {
#   instance = aws_instance.private.id
#   vpc      = true
# }
