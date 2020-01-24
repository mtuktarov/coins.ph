variable nodes {
  description = "List of a nodes we want to deploy"
  default     = ["kuber-master", "kuber-slave"]
}

variable cloud_config {
  description = "This is a path to cloud config."
  default     = "./cloud-init.conf"
}

variable cores {
  default = 2
}

variable memory {
  default = 2
}

variable fraction {
  default = 5
}

variable storage {
  default = 15
}

variable ssh_key_private {
  default = "/Users/mtuktarov/.ssh/id_rsa"
}

variable ansible_user {
  default = "mtuktarov"
}

variable static_ip_address{
    default = ["84.201.129.94", "84.201.156.54"]
}

variable ansible_playbook {
  default     = ["../ansible/playbooks/pb-k8s-master.yml", "../ansible/playbooks/pb-k8s-slave.yml"]
}

variable ansible_inventory {
  default     = ["../ansible/inventories/k8s.ini", "../ansible/inventories/k8s.ini"]
}