# Various tests with open tofu

## Documentation

- [Open Tofu documentation](https://opentofu.org/docs/cli/)
- [Terraform](https://developer.hashicorp.com/terraform?product_intent=terraform)
- [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## Tool setup

Avoid storing 300 MB for aws plugin per tf launch

    $ vi ~/.tofurc
    plugin_cache_dir = "$HOME/.terraform.d/plugin-cache"

Configure the backend

    $ cd global/s3
    $ tofu init
    $ tofu apply
    # uncomment backend in main.tf
    $ tofu init

## Help

### General

- [github terraform up and running](https://github.com/brikis98/terraform-up-and-running-code)
- [h2 use tf variables](https://spacelift.io/blog/how-to-use-terraform-variables)
- [Terraform Variables - A Standard](https://lachlanwhite.com/posts/terraform/10-11-2021-terraform-variables-a-standard/)

### IAM

- [Use AWS Managed Policies in Terraform](https://francescoboffa.com/terraform-aws-managed-policies/)