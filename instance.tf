# Template for the instances
resource "google_compute_instance_template" "default" {
  project     = "${var.project}"
  name        = "testserver-template"
  description = "This template is used to create test server instances."

  instance_description = "description assigned to instances"
  machine_type         = "f1-micro"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  network_interface {
    network = "default"
  }

  disk {
    source_image = "centos-cloud/centos-7"
    auto_delete  = true
    boot         = true
  }

  service_account {
    # Assign the cloud platform role to the instance
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance_from_template" "instance" {
  project = "${var.project}"
  
  # DEBUG: Initial pass use first line, to recreate bug, use second line
  count   = "2"
  #count   = "3"

  # Use the template for most parameters
  source_instance_template = "${google_compute_instance_template.default.self_link}"

  # Update the name, zone, and networking details
  name = "${lower(format("%s-%d", "instance-", count.index))}"
  zone = "${element(data.google_compute_zones.available.names, count.index)}"
}

resource "google_compute_instance_group" "group" {
  project = "${var.project}"
  count   = "2"
  name    = "${lower(format("%s-%d", "instance-group", count.index))}"

  zone = "${element(data.google_compute_zones.available.names, count.index)}"

  # DEBUG: Initial pass use first line, to recreate bug, use second line
  description = "INITIAL: Instance group ${count.index}"
  #description = "CHANGED: Instance group ${count.index}"

  instances = [
    "${matchkeys(concat(google_compute_instance_from_template.instance.*.self_link),
		concat(google_compute_instance_from_template.instance.*.zone),
        list(element(data.google_compute_zones.available.names, count.index))
	)}",
  ]

  lifecycle {
    ignore_changes = ["description"]
  }
}
