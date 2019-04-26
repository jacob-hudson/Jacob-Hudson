// Configure the Google Cloud provider
provider "google" {
 credentials = "${file("~/.gcp/creds.json")}"
 project     = "jacob-hudson.com"
 region      = "us-central"
}
