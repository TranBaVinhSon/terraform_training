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

Note that after you’ve used count on a resource, it becomes an array of resources rather than just one resource. Because `aws_iam_user.example` is now an array of IAM users, instead of using the standard syntax to read an attribute from that resource (`<PROVIDER>_<TYPE>.<NAME>.<ATTRIBUTE>`), you must specify which IAM user you’re interested in by specifying its index in the array using the same array lookup syntax: `<PROVIDER>_<TYPE>.<NAME>[INDEX].ATTRIBUTE`
For example:

```
output "all_arns" {
  value       = aws_iam_user.example[*].arn
  description = "The ARNs for all users"
}
```

#### Limitations

- `count` is not supported in `inline block`
- Deleting resource in array using `count`

---

### For each

`for_each` expressions, to loop over resources and inline blocks within a resource

```
resource "<PROVIDER>_<TYPE>" "<NAME>" {
  for_each = <COLLECTION>

  [CONFIG ...]
}
```

Example

```
resource "aws_iam_user" "example" {
  for_each = toset(var.user_names)
  name     = each.value
}
```

`toset` is used to convert list into a set.
`for_each` supports sets and maps only when used on a resource.
Once you’ve used for_each on a resource, it becomes a map of resources, rather than just one resource (or an array of resources as with `count`)

```
output "all_users" {
  value = aws_iam_user.example
}

$ terraform apply

(...)

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

all_users = {
  "morpheus" = {
    "arn" = "arn:aws:iam::123456789012:user/morpheus"
    "force_destroy" = false
    "id" = "morpheus"
    "name" = "morpheus"
    "path" = "/"
    "tags" = {}
  }
  "neo" = {
    "arn" = "arn:aws:iam::123456789012:user/neo"
    "force_destroy" = false
    "id" = "neo"
    "name" = "neo"
    "path" = "/"
    "tags" = {}
  }
  "trinity" = {
    "arn" = "arn:aws:iam::123456789012:user/trinity"
    "force_destroy" = false
    "id" = "trinity"
    "name" = "trinity"
    "path" = "/"
    "tags" = {}
  }
}
```

The fact that you now have a map of resources with `for_each` rather than an array of resources as with `count` is a big deal, because it allows you to remove items from the middle of a collection safely.

---

for expressions, to loop over lists and maps

for string directive, to loop over lists and maps within a string
