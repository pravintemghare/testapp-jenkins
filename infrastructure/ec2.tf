variable "instance_type" {
    type = string
    description = "input instance type for ec2 instance"
    default = "t2.micro"
}

variable "ami_id" {
    type = string
    description = "input ami id for ec2 instance"
}

variable "vpc_id" {
    type = string
    description = "input vpc id for ec2 instance"
}

variable "subnet_id" {
    type = string
    description = "input subnet id for ec2 instance"
}

variable "disk_size" {
    type = number
    description = "input disk size for ec2 instance"
    default = "8"
}

variable "server_name" {
    type = string
    description = "Name Tag for ec2 instance"
}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
    arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
data "aws_iam_policy" "AmazonEC2RoleforSSM" {
    arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}
data "aws_iam_policy" "CloudWatchActionsEC2Access" {
    arn = "arn:aws:iam::aws:policy/CloudWatchActionsEC2Access"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}


## Resources defined
resource "aws_security_group" "ec2_sg" {
    name        = "test-sg"
    description = "test ec2 security group"
    vpc_id      = var.vpc_id
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

resource "aws_iam_role" "web1role" {
    name = "ec2-instance-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Sid = ""
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            },
        ]
    })
    inline_policy {
        name = "TagRootVolumePolicy"
        policy = jsonencode({
            Version = "2012-10-17"
            Statement = [
                {
                    Action = "ec2:Describe*"
                    Effect = "Allow"
                    Resource = "*"
                },
                {
                    Action = "ec2:CreateTags"
                    Effect = "Allow"
                    Resource = "*"
                },
            ]
        })
    }
    managed_policy_arns = [data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn, data.aws_iam_policy.AmazonEC2RoleforSSM.arn, data.aws_iam_policy.CloudWatchActionsEC2Access.arn]
}  

resource "aws_iam_instance_profile" "EC2InstanceProfile" {
    name = "EC2InstanceProfile"
    path = "/"
    role = aws_iam_role.web1role.name
}

resource "aws_instance" "web1" {
    instance_type          = var.instance_type
    ami                    = var.ami_id
    vpc_security_group_ids = [aws_security_group.ec2_sg.id]
    subnet_id              = var.subnet_id
    iam_instance_profile   = aws_iam_instance_profile.EC2InstanceProfile.name
    root_block_device {  
        volume_size = var.disk_size
    }
    tags = {
        Name = var.server_name
    }    
}