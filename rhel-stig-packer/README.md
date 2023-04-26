# rhel-stig-packer

Packer build to create an ami with a RHEL 8 STIG applied and volumes mounted as launch block devices for:

- `/home`
- `/var/lib/rancher`
- `/var/lib/kubelet`
- `/var/log`
- `/var/log/audit`
- `/var/tmp`
- `/tmp`

## Usage

```sh
packer build -var-file=<some_var_file> .
```

To perform a debug build that allows you to manually step through each build phase:

```sh
packer build -debug .
```

Packer, by default, creates a temporary key pair that is only stored in-memory that is used as the key pair associated with the EC2 instanced launched in order to create an ami from. When run in debug mode, it will write the private key to disk in the directory Packer is being run from, and you can use that to ssh to the host while the build is paused in order to check out the machine and troubleshoot:

```sh
ssh -i ec2-rhel8.pem ec2-user@<ec2-public-ip>
```

Note that a public subnet is chosen intentionally to build in so that it is possible to assign a public IP. Otherwise, the SSM communicator would need to be used instead of ssh.

If there is ever any desire to reuse this template but in a different VPC or subnet, these values would need to be changed into variables that could be passed in. For now, this is not intended to be generic.


packer build \
-var "ami_name=Mike-Test-AMI" \
-var "aws_region=us-gov-east-1" \
-var "fips_enable=true" \
-var "instance_type=t3.2xlarge" \
-var "kms_key_id=d954f486-f83f-48d5-bfc7-ee3cde6375fa" \
-var "rhel_version=8.7" \
-var "stig_enable=true" \
-var "subnet_id=subnet-07a63ea291205ceea" \
-var "vpc_id=vpc-069f780b43a0e4149" \
.