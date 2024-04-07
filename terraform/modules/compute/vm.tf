resource "google_compute_address" "static_ip" {
  provider     = google
  name         = "static-ip"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
}

resource "google_compute_instance" "vpn" {
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  machine_type = "e2-micro"

  metadata = {
    startup-script = <<EOF
    wget https://git.io/vpnsetup -O vpnsetup.sh
    sudo VPN_IPSEC_PSK='${var.ipsec-psk}' VPN_USER='${var.ipsec-username}' VPN_PASSWORD='${var.ipsec-password}' sh vpnsetup.sh
    EOF
  }

  name = var.vm_name

  network_interface {
    access_config {
      nat_ip       = google_compute_address.static_ip.address
      network_tier = "PREMIUM"
    }
    network    = "default"
    stack_type = "IPV4_ONLY"
  }


  reservation_affinity {
    type = "ANY_RESERVATION"
  }

  scheduling {
    automatic_restart           = false
    instance_termination_action = "STOP"
    on_host_maintenance         = "TERMINATE"
    preemptible                 = true
    provisioning_model          = "SPOT"
  }


  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_vtpm                 = true
  }

  zone = "europe-west2-c"
}
