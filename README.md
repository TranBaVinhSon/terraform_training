<h1 align="center">Welcome to terraform_training 👋</h1>
<p>
</p>

## Show your support

Give a ⭐️ if this project helped you!

---

## Usage

Note: Terraform's version is 0.11

```
cd terraform_training/aws
terraform init
terraform apply
```

## Useful commands

- terraform fmt
- terraform validate

> When you applied your configuration, Terraform wrote data into a file called terraform.tfstate. This file now contains the IDs and properties of the resources Terraform created so that it can manage or destroy those resources going forward.
> You must save your state file securely and distribute it only to trusted team members who need to manage your infrastructure. In production, we recommend storing your state remotely. Remote stage storage enables collaboration using Terraform but is beyond the scope of this tutorial.

## Memo

- Assigning variables

```
terraform apply -var 'region=us-east-1'
```
