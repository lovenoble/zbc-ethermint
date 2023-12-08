# Terraform test environment

This allows running example testnet with 5 nodes, could be scaled up to 90.

To customize behaviour look into `variables.tf` file.

To not prompt public key prepare tfvars file with your public key:
```
echo 'ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFCo2+r+BHQXwUn0hgS2ZEP79RUmz9T6JUKfMw4f1iAe deividas@Deividass-MacBook-Pro.local"' > terraform.tfvars
```

## Running terraform

Run plan
```
terraform plan
```

Provision the resources
```
terraform apply
```

## Connecting to nodes

Once terraform apply succeeds, get public ip of the single vpn node with:
```
cat terraform.tfstate.backup | grep 'public_ip": "[0-9]'
```
Example output:
```
"public_ip": "35.177.70.69",
```

You can ssh to this node from which you'll reach all the other nodes in the setup. Only this node has public ip.

## VPN

To communicate/develop with other nodes you can use `sshuttle`
```
sshuttle -r ubuntu@35.177.70.69 10.0.0.0/24
```

After this you can ssh to the 5 (or more if you configured) worker nodes
```
ssh ubuntu@10.0.0.10
ssh ubuntu@10.0.0.11
ssh ubuntu@10.0.0.12
ssh ubuntu@10.0.0.13
ssh ubuntu@10.0.0.14
```

All worker nodes have only private ip and don't expose anything to the internet.

However, they have public internet access to download packages and etc.

All traffic is allowed between private nodes.
