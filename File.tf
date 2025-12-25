
# --- CAS 1 : BUCKET S3 SANS SÉCURITÉ ---
resource "aws_s3_bucket" "fail_bucket" {
  bucket = "mon-bucket-pas-securise"
  # On ne met rien d'autre : par défaut, c'est NON sécurisé, donc Checkov va le voir.
}

# --- CAS 2 : SECURITY GROUP OUVERT A TOUS ---
resource "aws_security_group" "fail_sg" {
  name        = "fail_sg"
  description = "Ouvert a tout le monde"

  ingress {
    description = "SSH pour tout le monde"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- CAS 3 : DISQUE DUR NON CHIFFRÉ ---
resource "aws_ebs_volume" "fail_drive" {
  availability_zone = "us-east-1a"
  size              = 10
  encrypted         = false
}