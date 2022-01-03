# Chapter 2

# Resource

```
# resource "<PROVIDER>_<TYPE>" "<NAME>" {
#  [CONFIG …]
# }
```

# Variable

```
variable "NAME" {
  [CONFIG ...]
}
```

Example

```tf
variable "object_example" {
  description = "An example of a structural type in Terraform"
  type        = object({
    name    = string
    age     = number
    tags    = list(string)
    enabled = bool
  })

  default = {
    name    = "value1"
    age     = 42
    tags    = ["a", "b", "c"]
    enabled = true
  }
}
```

```
var.<VARIABLE_NAME>
```

To use a reference inside of a string literal, we can use **interpolation**

```
"${...}"
```

## Output

```
output "<NAME>" {
  value = <VALUE>
  [CONFIG ...]
}
```

Example

```terraform
output "public_ip" {
  value       = aws_instance.example.public_ip
  description = "The public IP address of the web server"
}
```

## Data

A data source represents a piece of read-only information that is fetched from the provider (in this case, AWS) every time you run Terraform. Adding a data source to your Terraform configurations does not create anything new; it’s just a way to query the provider’s APIs for data and to make that data available to the rest of your Terraform code. Each Terraform provider exposes a variety of data sources. For example, the AWS provider includes data sources to look up VPC data, subnet data, AMI IDs, IP address ranges, the current user’s identity, and much more.

```
data "<PROVIDER>_<TYPE>" "<NAME>" {
  [CONFIG ...]
}
```

To get the data out of a data source, you use the following attribute reference syntax:

```
data.<PROVIDER>_<TYPE>.<NAME>.<ATTRIBUTE>
```

# Chapter 3: How to manage terraform state

Config backend for terraform state

```
terraform {
  backend "<BACKEND_NAME>" {
    [CONFIG...]
  }
}
```

# Chapter 4:

```
module "<NAME>" {
  source = "<SOURCE>"

  [CONFIG ...]
}
```

## Module Inputs

```
module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name           = "webservers-stage"
  db_remote_state_bucket = "(YOUR_BUCKET_NAME)"
  db_remote_state_key    = "stage/data-stores/mysql/terraform.tfstate"
}
```

## Module Locals

Local values allow you to assign a name to any Terraform expression, and to use that name throughout the module

```
locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}
```

```
local.<NAME>
```

## Module Outputs

In terraform, a module can also return values. For example in `/modules/services/webserver-cluster/outputs.tf`

```
output "asg_name" {
  value       = aws_autoscaling_group.example.name
  description = "The name of the Auto Scaling Group"
}
```

You can access module output variables using the following syntax

```
module.<MODULE_NAME>.<OUTPUT_NAME>
```

## Module Gotchas

#### File paths

`path.module` Returns the filesystem path of the module where the expression is defined.

`path.root` Returns the filesystem path of the root module.

`path.cwd` Returns the filesystem path of the current working directory.

#### Inline blocks

# Chapter 5

- Loops
- Conditionals
- Zero-downtime deployment
- Terraform gotchas

### Loops

`count` parameter, to loop over resources

```
resource "aws_iam_user" "example" {
  count = 3
  name  = "neo.${count.index}"
}
```

Using `count` with variables

```
variable "user_names" {
  description = "Create IAM users with these names"
  type        = list(string)
  default     = ["neo", "trinity", "morpheus"]
}
```

Putting these together, you get the following:

```
resource "aws_iam_user" "example" {
  count = length(var.user_names)
  name  = var.user_names[count.index]
}
```

for_each expressions, to loop over resources and inline blocks within a resource

for expressions, to loop over lists and maps

for string directive, to loop over lists and maps within a string
