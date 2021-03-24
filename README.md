## tf-nrec-node

Terraform module for a [NREC](https://nrec.no) instance

### Example

main.tf:
```
module "node" {
  source = "git@github.com:raykrist/tf-nrec-node.git"

  name              = "test"
  node_name         = "my-instance"
  region            = "bgo"
  node_count        = 2
  ssh_public_key    = "~/.ssh/id_rsa.pub"
  allow_ssh_from_v6 = ['2001:700:200::/48']
  allow_ssh_from_v4 = ['129.177.0.0/16']
  network           = "IPv6"
  flavor            = m1.medium
  image_name        = "GOLD Ubuntu 20.04"
  image_user        = "ubuntu" 
  volume_size       = 10
}

```

output.tf:
```
output "ansible_inventory_v6" {
  value = module.node.inventory_v6
}
```

Run:

```
terraform init
terraform apply
terraform output ansible_inventory_v6
```

