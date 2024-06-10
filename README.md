# vpn

Bootstraps a VM running as a VPN inside of a GCP region of your choosing.

Run `./hack/apply.sh` to get started.


# Issues

* terraform state not stored in external bucket for convenience when
  bootstrapping. As I intend to use this once in a while and destroy the
  environment immediately afterwards it is not a great concern.
* GCP shows the start-up script as custom metadata which contains secure
  credentials. Once again security risk mitigated by ephemeral environments.
