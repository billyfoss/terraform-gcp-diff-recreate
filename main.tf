provider "google" {
  credentials = "${file(var.gce_json)}"
  version     = "~> 1.20.0"
}

data "google_compute_zones" "available" {
  project = "${var.project}"
  region  = "${var.region}"
}

data "google_compute_image" "image" {
  project = "centos-cloud"
  family  = "centos-7"
}
