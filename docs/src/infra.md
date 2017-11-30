# Infrastucture environment

Tools used:

* Terraform
* Digital ocean
* Docker-compose

## SSH keys

Make sure your ssh key is in your digital ocean dashboard.

Now you need to start using ssh-agent, be sure it's loaded and running.

Load ssh key to ssh-agent:
```bash
ssh-add
```

## Prepare config

```
cp variables.tf.example variables.tf
```

Open `variables.tf`:
* add DO token (API tab).
* add ssh fingerprint from DO dashboard (Your profile -> Access)


## Cluster deployment

To deploy a cluster or any changes in it's setup - you need to install and run [Terraform](https://www.terraform.io).

```
cd terraform
terraform apply
```

It's a good practise to run `terraform plan` before applying changes, to see what's will be changed in infrastructure.

**WARNING**: Be VERY carefull using Terraform, if you remove something from script or resource will be changed too drastically, terraform might remove that resource and install new one, this can lead to data loss! Always use `terraform plan` before applying changes!

## Adding more nodes

In `variables.tf` file you can change these parameters to increase certain node count:

* `cluster_manager_count`
* `cluster_node_count`
* `cluster_gocd_agent_count`

After that run `terraform plan` to preview what changes will be made, and then only then `terraform apply`

## Docker container deployment

### Local docker setup

```bash
cp terraform/certs/ca.pem ~/.docker
cp terraform/certs/key.pem ~/.docker
cp terraform/certs/cert.pem ~/.docker
```
### Docker-compose usage

You need to specify which docker host you want to manage and authorize there to make changes:

```bash
cd compose
export DOCKER_HOST=tcp://<swarm_master_node_hostname_here>:2376
docker --tls stack deploy --compose-file=compose.yml infra
```

To get master node ip address do this:

```bash
cd terraform
terraform output
```

Or there's a Makefile your repo root folder:

Just do:
```bash
make deploy
```

### Destroying cluster

This will destroy all resources that terraform creted on AWS:

```bash
terraform destroy
```

**WARNING**: You will never use that unless setting up new cluster for testing.
