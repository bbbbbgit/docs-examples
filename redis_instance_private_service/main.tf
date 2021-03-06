resource "google_compute_network" "network" {
  name = "tf-test%{random_suffix}"
}

resource "google_compute_global_address" "service_range" {
  name          = "tf-test%{random_suffix}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.network.self_link
}

resource "google_service_networking_connection" "private_service_connection" {
  network                 = google_compute_network.network.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.service_range.name]
}

resource "google_redis_instance" "cache" {
  name           = "tf-test%{random_suffix}"
  tier           = "STANDARD_HA"
  memory_size_gb = 1

  location_id             = "us-central1-a"
  alternative_location_id = "us-central1-f"

  authorized_network = google_compute_network.network.self_link
  connect_mode       = "PRIVATE_SERVICE_ACCESS"

  redis_version     = "REDIS_3_2"
  display_name      = "Terraform Test Instance"

  depends_on = [ google_service_networking_connection.private_service_connection ]

}
