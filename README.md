to generate root ca use command
```
certstrap --depot-path root init \
    --organization "Example" \
    --common-name "Example Labs Root CA v1" \
    --expires "10 years" \
    --curve P-256 \
    --path-length 2 
```

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