# MTTR Summary — Advanced Chaos Engineering

| Scenario | Failure Start | Recovery Start | Recovery Complete | MTTR Notes |
|---|---|---|---|---|
| Dependency latency | See 06 | See 08 | See 09 | Latency restored after LATENCY_MS reset |
| Partial outage | See 10 | See 13 | See 14 | Dependency replicas restored |
| Resource exhaustion | See 15 | See 19 | See 20 | CPU stress job deleted |
| Alert routing failure | Manual observation | Manual recovery | Manual recovery complete | Alert routing validated through Prometheus/Alertmanager |
