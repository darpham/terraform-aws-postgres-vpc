# terraform-aws-postgres-vpc

Deploys a RDS instance running postgres 11 into a private VPC, with an ssh
bastion host for secure access.

You might use this for creating the backend for a webapp.

## Overview
This module will do the following:

1. create a VPC according to AWS best practice with public and private subnets.

2. create an RDS instance running Postgres 11 with no external ports visible to
   the internet. 

3. create a bastion server for securely accessing the database or other services within
   the VPC over SSH.

4. create an S3 bucket for storing the SSH public keys of users who will access
   the DB

5. stores useful information (vpc id, subnet ids, cidrs) securely in AWS SSM.

## Example

```hcl
module "networked_rds" {
  project_name = "ballotnav"
  stage = "dev"
  region = "us-west-2"
  account_id = "12345678910"

  ssh_public_key_names = ["alice", "bob", "carol"]
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]

  db_username = "ballotnav"
  db_name = "ballotnavdb"
  db_password = var.db_password
}
```

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_name | The overall name of the project using this infrastructure; used to group related resources by | `string` | `""` | yes |
| account\_id | the aws account id # that this is provisioned into | `string` | `""` | yes |
| stage | a short name describing the lifecyle or stage of development that this is running for; ex: 'dev', 'qa', 'prod', 'test'| `string` | `"dev"` | no |
| region | the aws region code where this is deployed; ex: 'us-west-2', 'us-east-1', 'us-east-2'| `string` | `""` | yes |
| cidr_\block |The range of IP addresses this vpc will reside in| `string` | `"10.10.0.0/16"` | no |
| availability_zones |The region + identifiers for the zones that the vpc will cover. Ex: ['us-west-2a', 'us-west-2b', 'us-west-2c']. Varies between regions.| `string` | `""` | yes |
| tags| key value map of tags applied to infrastructure | `map` |
`{terraform_managed = "true"}` | no |
| db\_username | The name of the default postgres user created by RDS when the instance is booted| `string` | `""` | yes |
| db\_name |The name of the default postgres database created by RDS when the instance is booted | `string` | `""` | yes |
| db\_password |The postgres database password created for the default database when the instance is booted. :warning: do not put this into git!| `string` | `""` | yes |
| ssh\_public\_key\_names |the name of the public key files in ./public_keys without the file extension; example ['alice', 'bob', 'carol']| `list(string)` | `""` | yes |

## Bastion server
A [bastion
server](https://docs.aws.amazon.com/quickstart/latest/linux-bastion/overview.html)
is a hardened server through which access to resources running in private
subnets of a VPC. An example use case is a database. Rather than create a
database with ports open to the whole wide Internet we can create it within our
own virtual cloud, and grant access to it via the bastion, aka "jumpbox", server.

The bastion server here is composed from the very good [terraform community
module](https://github.com/terraform-community-modules/tf_aws_bastion_s3_keys/tree/v2.0.0).

To grant users access via the bastion to VPC resources simply add their SSH
public key to the S3 bucket created by this blueprint. The server syncs its keys
with that bucket hourly so that every time a key is added or removed, that users
access is added or removed with it. 

### bastion usage
create a folder called `public_keys` in the directory from where you are
applying this terraform configuration.

```bash
mkdir -p public_keys
```

create an SSH key pair and copy the public key to the `public_keys` folder. [Read more on generating ssh keys](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh)

```bash
ssh-keygen -t rsa -m PEM -b 4096 -C "myname@example.com" -N "" -f myname
Generating public/private rsa key pair.
Your identification has been saved in myname.
Your public key has been saved in myname.pub.
The key fingerprint is:
SHA256:qbP4peCX8+g2PvyJXCNs6Qz4fQo04em7sNzst2k4YSw myname.pub
The key's randomart image is:
+---[RSA 4096]----+
|                 |
|                 |
|    .            |
|   . o   .       |
|   .=   S        |
|  E++o o         |
|  oo=+B.+        |
| . Bo%@@.o       |
|  o.X@^X+        |
+----[SHA256]-----+
```

Finally run `terraform plan` and `terraform apply` and any public keys in that `public_keys` folder will be synced to the S3 bucket and to the bastion server.

#### connect to the Postgres database via the bastion server
We can connect to the database via the bastion using [SSH local port
forwarding](https://www.ssh.com/ssh/tunneling/example).

Many database clients will have an option to configure a connection via SSH.

After successfully applying this blueprint terraform will output
the `db_address` and the `eip_public_address` and these will be the values used
to connect to postgres.
