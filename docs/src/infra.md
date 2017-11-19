# Infrastucture environment

It's a docker swarm based environment separated from Pitchup to host infrastructure tools.

Tools used:

* Terraform
* AWS EC2
* AWS VPC
* Docker-compose

## SSH keys

Copy ssh key:

```bash
cp docker-infra/terraform/pitchup.pem ~/.ssh/pitchup.pem
chmod 600 ~/.ssh/pitchup.pem
```

Now you need to start using ssh-agent, be sure it's loaded and running. 

Load ssh key to ssh-agent:
```bash
ssh-add .ssh/do.pem
```

## Cluster deployment

To deploy a cluster or any changes in it's setup - you need to install and run [Terraform](https://www.terraform.io).

```
cd docker-infra/terraform
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
cp docker-infra/terraform/certs/ca.pem ~/.docker
cp docker-infra/terraform/certs/key.pem ~/.docker
cp docker-infra/terraform/certs/cert.pem ~/.docker
```
### Docker-compose usage

You need to specify which docker host you want to manage and authorize there to make changes:

```bash
cd docker-infra/compose
export DOCKER_HOST=tcp://<swarm_master_node_hostname_here>:2376
docker --tls stack deploy --compose-file=compose.yml infra
```

To get master node ip address do this:

```bash
cd docker-infra/terraform
terraform output
```

Or there's a Makefile `docker-infra/` directory:

Just do:
```bash
make deploy
```

### Force update image

You might need to set DOCKER_HOST for that node where image is stored
```
docker --tls pull pitchup/gocd-server:latest
```

Force update service

```
docker --tls service update --force --detach=false infra_gocd-server
```

### Destroying cluster

This will destroy all resources that terraform creted on AWS:

```bash
terraform destroy
```

**WARNING**: You will never use that unless setting up new cluster for testing.
