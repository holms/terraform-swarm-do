variable "token" {
    default = "9fa5ec7efd4cd2b59f25845a39b65a09e59866de2d54b4c8c3d10941ef4cb653"
    description = "Cloud provider token"
}

variable "ssh_keys" {
    default = ["0f:e6:9c:fe:73:2d:e6:08:c6:7d:36:b2:64:62:f4:ef"]
    description = "Key signature from digital ocean"
}


variable "cluster_manager_count" {
    description = "Number of manager instances for the cluster."
    default = 1
}

variable "cluster_slave_count" {
    description = "Number of slave instances for the cluster."
    default = 1
}


