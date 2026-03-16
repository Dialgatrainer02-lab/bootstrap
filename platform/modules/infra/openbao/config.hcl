ui = true

log_level = "trace"

log_requests_level = "trace"


listener "tcp" {
    tls_disable = 1
    address = "[::]:8200"
    cluster_address = "[::]:8201"
}


storage "raft" {
    path = "/openbao/data"

}


seal "static" {
    current_key_id = "test-1"
    current_key = "file:///secrets/test-1.key"
}