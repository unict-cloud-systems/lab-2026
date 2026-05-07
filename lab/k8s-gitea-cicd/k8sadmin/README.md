# k8sadmin — Kubernetes Administration Lab

Practical scripts and configs for Day 2 K8s operations used alongside the
`K8S-gitea-cicd` slide deck.

## Structure

```
k8sadmin/
├── metrics-server/
│   └── install.sh          # Deploy Metrics Server + Multipass patch
└── monitoring/
    ├── install.sh           # Deploy kube-prometheus-stack via Helm
    ├── cleanup.sh           # Remove stack + CRDs
    └── values.yaml          # Resource-tuned Helm values for Multipass
```

## Quick Start

```bash
# 1. Metrics Server (kubectl top)
bash metrics-server/install.sh

# 2. Full Prometheus + Grafana stack
bash monitoring/install.sh

# Or with custom password:
GRAFANA_PASSWORD=mysecret bash monitoring/install.sh

# 3. Access Grafana (NodePort 32000 via values.yaml)
# http://<control-plane-ip>:32000   admin / admin

# 4. Teardown
bash monitoring/cleanup.sh
```

## Prerequisites

- `helm` ≥ 3.x installed on the machine running these scripts
- `kubectl` configured with a valid kubeconfig pointing at the cluster
- Cluster provisioned via `../k8s-gitea-cicd/terraform/`
