# mobile-java-backend

Standards for Java/Spring Boot backend development at mobile.de.

## Stack

- Java 17+ with Spring Boot 3.x
- Spring Data MongoDB for persistence
- Spring Security for authentication
- Maven or Gradle for build
- JUnit 5 + Mockito for unit tests
- Testcontainers for integration tests (real MongoDB, no mocks)

## API conventions

- REST endpoints follow mobile.de API gateway conventions (see `openspec/specs/` for any declared API contracts)
- Request/response DTOs are record classes (Java 16+)
- Validation: Jakarta Bean Validation (`@NotBlank`, `@Size`, `@Pattern`) on DTOs
- Error responses: problem+json (`application/problem+json`) with `type`, `title`, `status`, `detail`

## Phone number handling

Phone numbers are stored and returned in E.164 format: `+<country-code><local-number>` with no separators.
- `+49170123456` is valid
- `0170123456` is not valid (no country code)
- Validation regex: `^\+[1-9]\d{6,14}$`

## Data access

- Repository layer: Spring Data `@Repository` interfaces
- No business logic in repository classes — pure CRUD
- Services own all business rules
- Never expose MongoDB `_id` directly in APIs — map to a `<domain>Id` string field

## Security and GDPR

- PII fields (name, email, phone, dateOfBirth, identificationNumber) must not appear in logs
- Use `@JsonIgnore` or custom serializer to mask PII in log output
- All access to personal data must be authorized via Spring Security method security (`@PreAuthorize`)
- See `mde-security-gdpr` skill for full GDPR requirements

## Testing

- Integration tests use Testcontainers MongoDB — never mock the database
- Unit tests mock only external HTTP clients, never internal services
- Test class names: `<ClassName>Test` (unit), `<ClassName>IT` (integration)

## Code style

- No comments that describe what the code does
- Method names are verbs: `createContract`, `findByContractId`, `mapToDto`
- DTOs are immutable records; domain objects are classes
- Checked exceptions are forbidden — use unchecked (`RuntimeException` subclasses) with Spring's exception handler
