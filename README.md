# WORK IN PROGRESS

---

# Camunda BPM Platform Enterprise Helm Chart

---

Original helm chart was here: https://github.com/camunda-community-hub/camunda-7-community-helm

---

Enterprise-ready Camunda BPM Platform 7 Helm chart with full Istio service mesh integration and robust PostgreSQL database handling.

## TL;DR

```bash
helm repo add lazarevcloud https://helm.lazarev.cloud
helm repo update
helm install my-camunda lazarevcloud/camunda-7-bpm-platform
```

## Features

- Full Istio service mesh integration
  - Traffic management
  - Security policies
  - Observability
  - Circuit breakers and retry policies
- Robust PostgreSQL integration
  - High availability options
  - Connection pooling
  - Automated failover
- Enhanced security
  - mTLS support
  - JWT authentication
  - Network policies
- Comprehensive monitoring
  - Prometheus metrics
  - Grafana dashboards
  - Health checks
- Production-ready defaults
  - Resource management
  - Autoscaling
  - Persistence

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- Istio 1.12+ (if using service mesh features)

## Installing the Chart

To install the chart with the release name `my-camunda`:

```bash
helm install my-camunda lazarevcloud/camunda-bpm-platform
```

## Configuration

See [values.yaml](./values.yaml) for the full list of parameters.

### Key Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `istio.enabled` | Enable Istio integration | `true` |
| `postgresql.enabled` | Enable built-in PostgreSQL | `true` |
| `postgresql.ha.enabled` | Enable PostgreSQL HA | `false` |
| `ingress.enabled` | Enable ingress | `true` |
| `metrics.enabled` | Enable Prometheus metrics | `true` |

## Documentation

[Complete documentation](https://docs.camunda.org/manual/7.18/)
