# Camunda BPM Platform Enterprise Helm Chart

![Version: 8.0.0](https://img.shields.io/badge/Version-8.0.0-informational?style=flat-square)
![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)
![AppVersion: 7.x.x](https://img.shields.io/badge/AppVersion-7.x.x-informational?style=flat-square)

Enterprise-ready Camunda BPM Platform 7 Helm chart with full Istio service mesh integration and robust PostgreSQL database handling.

## TL;DR

```bash
helm repo add lazarevcloud https://lazarev.cloud
helm repo update
helm install my-camunda lazarevcloud/camunda-bpm-platform
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

## License

Copyright &copy; 2024 LazarevCloud

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.