output "master.ip" {
  value = "${digitalocean_droplet.swarm-master.ipv4_address}"
}

output "private_dns" {
  value = "${digitalocean_droplet.swarm-master.ipv4_address_private}"
}
