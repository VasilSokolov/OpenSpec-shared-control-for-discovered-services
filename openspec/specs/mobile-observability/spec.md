# mobile-observability — Logging, Tracing, and Metrics Standards

status: stub — fill with actual observability stack and standards

## What this spec covers

How all mobile.de services produce structured logs, distributed traces, and
metrics, and how dashboards and alerts are configured.

## Required information (to be filled)

- Logging library: `@mobile-de/logger`, pino, winston, or other
- Log format standard: JSON schema, required fields (correlationId, service,
  level, timestamp, message, requestId, userId-hash)
- PII rules: which fields must never appear in logs (email, phone, dateOfBirth,
  identificationNumber, full names)
- Tracing backend: Jaeger, Zipkin, Datadog APM, or other
- Trace header standard: `x-request-id`, `traceparent`, or other
- Metrics backend: Prometheus, Datadog, Graphite, or other
- Metric naming convention (snake_case, dot notation, etc.)
- Alert routing: how critical alerts reach on-call
- Dashboard location for each service tier
- Log retention policy per environment

## Standards gates (enforced by mobile-observability capability)

Before any observability-impacting change is committed:

1. Structured log calls include all required fields (no string concatenation)
2. No PII fields in any log statement or trace attribute
3. Correlation ID is propagated through all async calls
4. New metrics follow the naming convention and are documented
5. Alert threshold change requires on-call review

## Links

- [ ] Add logging library docs link
- [ ] Add Grafana / dashboard URL
- [ ] Add on-call runbook link
