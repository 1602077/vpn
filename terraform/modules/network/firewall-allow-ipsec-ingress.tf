resource "google_compute_firewall" "allow_ipsec_ingress" {
  allow {
    ports    = ["500", "4500"]
    protocol = "udp"
  }

  direction     = "INGRESS"
  name          = "allow-ipsec-ingress"
  network       = "default"
  priority      = 999
  source_ranges = ["0.0.0.0/0"]
}
