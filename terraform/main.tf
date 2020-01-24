//export YC_SERVICE_ACCOUNT_KEY_FILE=~/.yandex/key.json && terraform plan
provider "yandex" {
  token = "AgAAAAA8ZZ9OAATuwVW_K9Cvc0IotBZCawuEN1I"
  cloud_id                 = "aje8i16hns9b9cgubosl"
  folder_id                = "b1gata3eq3dtejlf552k"
  zone                     = "ru-central1-a"
}

data "yandex_compute_image" "centos" {
  family = "centos-7"
}

resource "yandex_compute_instance" "vm" {
  count    = length(var.nodes)
  name     = var.nodes[count.index]
  hostname = var.nodes[count.index]

  resources {
    cores         = var.cores
    memory        = var.memory
    core_fraction = var.fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.centos.id
      size     = var.storage
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    user-data = file(var.cloud_config)
  }

   connection {
    host = self.network_interface[0].nat_ip_address
    user = var.ansible_user
    private_key = file(var.ssh_key_private)
  }
  provisioner "ansible" {
    plays {
      playbook {
        file_path = var.ansible_playbook[count.index]
      }
      forks = 5
      verbose = false
    }
    ansible_ssh_settings {
      connect_timeout_seconds = 10
      connection_attempts = 10
      ssh_keyscan_timeout = 60
      insecure_no_strict_host_key_checking = false
      insecure_bastion_no_strict_host_key_checking = false
      user_known_hosts_file = ""
      bastion_user_known_hosts_file = ""
    }
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["10.211.55.0/24"]
}

output "internal_ip_address" {
  value = "${
    formatlist(
      "%s:%s",
      yandex_compute_instance.vm.*.hostname,
      yandex_compute_instance.vm.*.network_interface.0.ip_address
    )
  }"
}

output "external_ip_address" {
  value = "${
    formatlist(
      "%s:%s",
      yandex_compute_instance.vm.*.hostname,
      yandex_compute_instance.vm.*.network_interface.0.nat_ip_address
    )
  }"
}

