to generate root ca use command
```
certstrap --depot-path root init \
    --organization "Example" \
    --common-name "Example Labs Root CA v1" \
    --expires "10 years" \
    --curve P-256 \
    --path-length 2 
```
the signing command to generate an intermediate is
```
set -euo pipefail
certstrap --depot-path root sign \
    --CA "Example Labs Root CA v1" \
    --intermediate \
    --csr "$CSR_FILE" \
    --expires "5 years" \
    --path-length 1 \
    --cert "$SIGNED_CERT_FILE" \
    "Example Labs Intermediate CA v1.1"
```
the local mirror takes a while so apply it first
`tofu apply -target=module.dev.module.local_mirror`

## Infrastructure Services To Complete

- [x] internal package mirror
- [x] internal certificate authority
- [ ] internal container registry
- [ ] dns
- [ ] ntp
- [ ] internal git server
- [ ] management talos cluster (single node)
- [ ] vector logging agents
- [ ] vector aggregator

# todo list
- setup local oci repo (wip)
- setup dns server
- setup vector logging agent + agregator
- (low) secure package repo and openbao with https
- setup proxmox sdn for proper air gapping

## Test Plan (Complex Areas)

Current tests cover basic module behavior for `vm`, `datastore`, `local_mirror`, and `oci_container`. The following higher-risk areas should be added next:

- [ ] `infra` feature-gate orchestration (`local_mirror`, `openbao`, `local_registry`) with plan assertions to verify the correct modules are created or skipped for each gate combination.
- [ ] Service network addressing logic in `modules/infra` (CIDR host allocation, prefix formatting, gateway wiring) to prevent IP collisions and invalid address rendering.
- [ ] OpenBao PKI mount and issuer chain flow (`pki_int` -> `pki_iss`) to validate backend paths, issuer references, and dependency ordering.
- [ ] OpenBao issuing role policy validation: `allowed_domains` derived from `service_dns_domain`, `allow_subdomains`, `allow_ip_sans`, and `no_store=true` (needed for ACME use-cases).
- [ ] OpenBao URL/cluster config correctness (`issuing_certificates`, `crl_distribution_points`, `ocsp_servers`, cluster `path`/`aia_path`) to ensure generated cert metadata points to reachable endpoints.
- [ ] OpenBao module integration outputs (`api_address`, `admin_username`, `config_kv_mount_path`, `intermediate_ca_certificate`) to ensure downstream modules/providers can consume them safely.
- [ ] Negative validation tests for invalid or empty domain-related inputs (for example `service_dns_domain = ""`) to ensure role defaults/fallbacks behave predictably.

### testing vault
make a test helper module to spin up a local openbao (using  a docker image) and reset the vault provider config in the test so it uses the root token from the dev server to apply against so we dont rely on proper infra