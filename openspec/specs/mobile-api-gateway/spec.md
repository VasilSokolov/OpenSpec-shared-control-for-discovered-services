# mobile-api-gateway — API Gateway Standards

status: stub — fill with actual gateway configuration and routing standards

## What this spec covers

How mobile.de routes requests through the API gateway layer, including Istio
service mesh, BFF patterns, authentication enforcement, rate limiting, and
circuit breakers.

## Required information (to be filled)

- Gateway technology (Istio, Kong, Envoy, or other)
- Helm chart location for VirtualService / DestinationRule configuration
- BFF pattern: which frontends have a Backend-for-Frontend layer
- Authentication enforcement point: where Bearer/session token is validated
- Rate limiting policy per service and per user
- Circuit breaker settings (threshold, open duration, half-open probes)
- Retry policy: which endpoints allow retries, max attempts, backoff
- Timeout standards per service tier (frontend calls, internal service calls)
- Header forwarding policy: correlation IDs, trace headers, user context
- CORS configuration — allowed origins per environment
- How gateway configuration is tested before deployment (canary, shadow traffic)

## Standards gates (enforced by mobile-api-gateway capability)

Before any gateway configuration change is committed:

1. `mde-api-contract` skill must have run — route change has an approved contract
2. `mde-postman` skill must have run — Postman collection validates the route
3. `mde-observability` skill must have run — new route emits trace headers and
   access logs following the standard schema
4. `mde-security-gdpr` skill must have run — auth enforcement verified at gateway
5. Rollback procedure documented in the release plan

## Links

- [ ] Add Helm chart repository link
- [ ] Add Istio configuration docs link
- [ ] Add Postman gateway collection link
