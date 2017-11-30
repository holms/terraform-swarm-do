resource "digitalocean_droplet" "swarm-master" {

  name                          = "swarm-master"
  image                         = "ubuntu-16-10-x64"
  region                        = "${var.region}"
  size                          = "${var.memory_master}"
  ssh_keys                      = "${var.ssh_keys}"
  private_networking            = 1
  count                         = 1

  connection {
    user = "root"
    agent = 1
  }

  provisioner "file" {
    source      = "cfg/systemd.conf"
    destination = "/tmp/docker.conf"
  }
  provisioner "file" {
    source      = "certs"
    destination = "/tmp/ssl"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /etc/systemd/system/docker.service.d",
      "mv /tmp/docker.conf /etc/systemd/system/docker.service.d/10-ssl.conf",
      "mkdir -p /etc/docker/ssl",
      "mv /tmp/ssl /etc/docker",
      "apt-get update",
      "apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "apt-get update",
      "apt-get install -y docker-ce",
      "cp /lib/systemd/system/docker.service /etc/systemd/system/",
      "sed -i 's/\\ -H\\ fd:\\/\\// -H\\ unix:\\/\\/\\/var\\/run\\/docker\\.sock\\ -H\\ tcp:\\/\\/0\\.0\\.0\\.0:2375/g' /etc/systemd/system/docker.service",
      "systemctl daemon-reload",
      "systemctl restart docker.service",
      "docker swarm init --advertise-addr ${digitalocean_droplet.swarm-master.0.ipv4_address_private}",
      "docker node update --label-add name=master ${self.name}",
    ]
  }
}

resource "digitalocean_droplet" "swarm-manager" {
  name                          = "swarm-manager"
  image                         = "ubuntu-16-10-x64"
  region                        = "${var.region}"
  size                          = "${var.memory_manager}"
  ssh_keys                      = "${var.ssh_keys}"
  private_networking            = 1
  count                         = "${var.cluster_manager_count}"

  connection {
    user = "root"
    agent = 1
  }

  provisioner "file" {
    source      = "cfg/systemd.conf"
    destination = "/tmp/docker.conf"
  }
  provisioner "file" {
    source      = "certs"
    destination = "/tmp/ssl"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /etc/systemd/system/docker.service.d",
      "mv /tmp/docker.conf /etc/systemd/system/docker.service.d/10-ssl.conf",
      "mv /tmp/ssl /root/.docker",
      "mkdir -p /etc/docker/ssl",
      "cp /root/.docker/* /etc/docker/ssl/",
      "apt-get update",
      "apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "apt-get update",
      "apt-get install -y docker-ce",
      "cp /lib/systemd/system/docker.service /etc/systemd/system/",
      "sed -i 's/\\ -H\\ fd:\\/\\// -H\\ unix:\\/\\/\\/var\\/run\\/docker\\.sock\\ -H\\ tcp:\\/\\/0\\.0\\.0\\.0:2375/g' /etc/systemd/system/docker.service",
      "systemctl daemon-reload",
      "systemctl restart docker.service",
      "docker swarm join --token $(docker --tls -H ${digitalocean_droplet.swarm-master.0.ipv4_address_private}:2376 swarm join-token -q manager) ${digitalocean_droplet.swarm-master.0.ipv4_address_private}:2377",
      "docker node update --label-add name=manager-${count.index} ${self.name}",
    ]
  }

  depends_on = [
      "digitalocean_droplet.swarm-master"
  ]
}

resource "digitalocean_droplet" "swarm-slave" {
  name                          = "swarm-slave"
  image                         = "ubuntu-16-10-x64"
  region                        = "${var.region}"
  size                          = "${var.memory_slave}"
  ssh_keys                      = "${var.ssh_keys}"
  private_networking            = 1
  count                         = "${var.cluster_slave_count}"

  connection {
    user = "root"
    agent = 1
  }

  provisioner "file" {
    source      = "certs"
    destination = "/tmp/ssl"
  }
  provisioner "file" {
    source      = "cfg/systemd.conf"
    destination = "/tmp/docker.conf"
  }
  provisioner "remote-exec" {
    inline = [
      "sysctl -w vm.max_map_count=262144",
      "mkdir -p /etc/systemd/system/docker.service.d",
      "mv /tmp/docker.conf /etc/systemd/system/docker.service.d/10-ssl.conf",
      "mv /tmp/ssl /root/.docker",
      "mkdir -p /etc/docker/ssl",
      "cp /root/.docker/* /etc/docker/ssl/",
      "apt-get update",
      "apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "apt-get update",
      "apt-get install -y docker-ce",
      "cp /lib/systemd/system/docker.service /etc/systemd/system/",
      "sed -i 's/\\ -H\\ fd:\\/\\// -H\\ unix:\\/\\/\\/var\\/run\\/docker\\.sock\\ -H\\ tcp:\\/\\/0\\.0\\.0\\.0:2375/g' /etc/systemd/system/docker.service",
      "systemctl daemon-reload",
      "systemctl restart docker.service",
      "docker swarm join --token $(docker --tls -H ${digitalocean_droplet.swarm-master.0.ipv4_address_private}:2376 swarm join-token -q worker) ${digitalocean_droplet.swarm-master.0.ipv4_address_private}:2377",
      "docker --tls -H ${digitalocean_droplet.swarm-master.0.ipv4_address_private}:2376 node update --label-add name=slave ${self.name}",
    ]
  }
  depends_on = [
      "digitalocean_droplet.swarm-manager"
  ]
}

