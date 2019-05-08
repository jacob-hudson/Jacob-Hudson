// Configure the Google Cloud provider
provider "google" {
 credentials = "${file("~/.gcp/creds.json")}"
 project     = "${var.project_name}"
 region      = "us-central1"
}


// Terraform plugin for creating random ids
resource "random_id" "instance_id" {
 byte_length = 8
}

// A single Google Cloud Engine instance
resource "google_compute_instance" "default" {
 name         = "jacob-hudson-${random_id.instance_id.hex}"
 machine_type = "f1-micro"
 zone         = "us-central1-a"

 boot_disk {
   initialize_params {
     image = "ubuntu-os-cloud/ubuntu-1404-trusty-v20190424"
   }
 }

 metadata {
   ssh-keys = "${var.ssh_user}:${file("${var.public_key_path}")}"
 }

// Make sure flask is installed on all new instances for later steps
 metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python-pip rsync; pip install flask"

 network_interface {
   network = "default"

   access_config {
     // Include this section to give the VM an external ip address
   }
 }
  provisioner "remote-exec" {
    inline = ["echo 'Hello World'"]

    connection {
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file("${var.private_key_path}")}"
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i '${google_compute_instance.default.network_interface.0.access_config.0.nat_ip},' --private-key ${var.private_key_path} ../ansible/task/docker.yml"
  }
}
