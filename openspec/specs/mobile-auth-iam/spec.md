# mobile-auth-iam — Authentication and IAM Standards

status: stub — fill with actual mobile.de auth patterns before first auth task

## What this spec covers

Authentication, session management, SSO, and role-based access patterns used
across all mobile.de applications.

## Required information (to be filled)

- SSO provider and endpoint (Keycloak URL, realm, client IDs)
- Token storage policy (httpOnly cookie, memory, localStorage — which is approved)
- Session lifetime and refresh policy
- RBAC roles relevant to mobile.de product surfaces
- Service-to-service auth pattern (mTLS, service accounts, scopes)
- Frontend auth library (`@mobile-de/auth`, next-auth, etc.)
- Auth middleware pattern for Next.js App Router
- How authentication state is passed to server components vs client components
- Required logout / session invalidation flow
- Approved CORS origins and credentials policy

## Standards gates (enforced by mobile-auth-iam capability)

Before any auth-related task is committed:

1. `mde-security-gdpr` skill must have run — OWASP auth checklist complete
2. Token storage must match the approved policy above
3. No secrets or tokens logged or traced (mde-observability enforces this)
4. Integration tests must cover login, refresh, logout, and expired-token flows
5. Penetration testing required for new auth boundaries

## Links

- [ ] Add Keycloak admin console URL
- [ ] Add IAM runbook link
- [ ] Add auth library docs link
