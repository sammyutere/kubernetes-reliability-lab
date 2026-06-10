# SLIs, SLOs and Error Budgets

## Purpose

Define reliability targets for the multi-service application.

## SLIs

### Availability

```promql
sum(rate(frontend_http_requests_total{status=~"2.."}[5m]))
/
sum(rate(frontend_http_requests_total[5m]))
```
## Error Rate

```promql
sum(rate(frontend_http_requests_total{status=~"5.."}[5m]))
/
sum(rate(frontend_http_requests_total[5m]))
```
## Latency

```promql
histogram_quantile(
  0.95,
  sum(rate(frontend_http_request_duration_seconds_bucket[5m])) by (le)
)
```
## SLOs

| SLO          | Target                    |
| ------------ | ------------------------- |
| Availability | 99.9% successful requests |
| Error rate   | < 0.1% 5xx responses      |
| Latency      | p95 < 500ms               |

## Error Budget Policy

If error budget is healthy:

```txt
Normal releases allowed
```
If error budget is nearly exhausted:

```txt
Canary-only releases
```
If error budget is exhausted:

```txt
Feature releases paused; reliability work takes priority
```

