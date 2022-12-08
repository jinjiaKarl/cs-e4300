terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.37.0"
    }
  }
}

provider "google" {
  project = "cloudsoftware-362517"
  region  = "us-central2"
  zone    = "europe-central2-a"
}

data "google_compute_image" "my_image" {
  family  = "ubuntu-2004-lts"
  project = "ubuntu-os-cloud"
}

resource "google_compute_instance" "vm_instance" {
  name = "server"
  machine_type = "n1-standard-2"
  //machine_type     = "f1-micro"
  min_cpu_platform = "Intel Haswell"
  tags             = ["ssh"]
  advanced_machine_features {
    enable_nested_virtualization = true
  }

  boot_disk {
    initialize_params {
      image = data.google_compute_image.my_image.self_link
      size = "20"
    }
  }

  network_interface {
    network = "default"

    access_config {}
  }
  // refer to https://gist.github.com/smford22/54aa5e96701430f1bb0ea6e1a502d23a
  connection {
    type        = "ssh"
    user        = "gcpuser"
    host        = "${google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip}"
    port        = 22
    private_key = file("~/.ssh/id_rsa")
  }
  provisioner "file" {
    source      = "../start.sh"
    destination = "/tmp/start.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/start.sh",
      "/tmp/start.sh",
    ]
  }

  metadata = {
    ssh-keys = "gcpuser:${file("~/.ssh/id_rsa.pub")}"
  }
}