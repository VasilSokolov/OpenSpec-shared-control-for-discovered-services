# Spring Boot 4.0 Migration Troubleshooting

## Issue 1: Compilation Errors After Update

**Symptom**: Code doesn't compile after updating versions.

**Common causes**:
- Deprecated Spring Security APIs (`WebSecurityConfigurerAdapter`, `antMatchers()`)
- Health package moved: `org.springframework.boot.actuate.health.*` → `org.springframework.boot.health.contributor.*`
- Changed Hibernate APIs
- Jakarta EE imports not updated (`javax.*` → `jakarta.*`)

**Resolution**:
```bash
mvn compile 2>&1 | tee compile-errors.log
grep "cannot find symbol\|package does not exist" compile-errors.log
```

See `springboot-4-breaking-changes.md` for specific API changes and fixes.

## Issue 2: Tests Fail with Container Errors

**Symptom**: Tests fail with MySQL/Testcontainers errors after migration.

**Resolution**: Add test-jar dependency for `mobile-domain-spring-boot-starter`:
```xml
<dependency>
    <groupId>de.mobile.spring.boot.starter</groupId>
    <artifactId>mobile-domain-spring-boot-starter</artifactId>
    <type>test-jar</type>
    <scope>test</scope>
</dependency>
```

## Issue 3: Application Fails to Start

**Symptom**: Application starts but fails during bean creation.

**Common causes**:
- Missing `mobile-http-client-spring-boot-starter` (if autowiring `WebClient`/`RestClient`)
- Invalid or removed configuration properties
- Bean definition conflicts from dependency changes

**Resolution**:
```bash
mvn spring-boot:run -Dspring-boot.run.arguments="--debug"
mvn dependency:analyze
```

## Issue 4: WebClient/RestClient Not Autowiring

**Symptom**: `@Autowired WebClient` or `@Autowired RestClient` fails with no qualifying bean.

**Resolution**: Add `mobile-http-client-spring-boot-starter` — it is no longer transitively included via metrics starters.

```xml
<dependency>
    <groupId>de.mobile.spring.boot.starter</groupId>
    <artifactId>mobile-http-client-spring-boot-starter</artifactId>
</dependency>
```

## Issue 5: Actuator Endpoints Return 404

**Symptom**: `/actuator/health` and other endpoints are not accessible.

**Resolution**:
```properties
management.endpoints.web.exposure.include=health,info,metrics
management.endpoint.health.show-details=when-authorized
```

## Issue 6: Tests Fail with Log File Not Found

**Symptom**: Tests fail with `FileNotFoundException: test.log`

**Cause**: Tests rely on file-based logging which is no longer configured.

**Resolution**: Implement `TestLogAppender` pattern. See `reactive-webflux-test-logging.md`.

## Issue 7: Metrics Not Exported (After BOM 4.0.5 Upgrade)

**Symptom**: Application starts but metrics aren't sent to Graphite.

**Cause**: `mobile-spring-boot-bom` 4.0.5 dropped Graphite support entirely. Graphite metrics will no longer work regardless of configuration.

**Resolution**: Remove all Graphite dependencies and configuration. For batch jobs or short-lived processes that need to push metrics, configure Prometheus Pushgateway instead:

```yaml
metrics:
  prometheus:
    pushgateway:
      address: <pushgateway-host>:<port>
```

No additional dependency is needed when `mobile-metrics-spring-boot-starter` is present.

## Issue 8: Jackson Deserialization Fails

**Symptom**: JSON deserialization throws `ClassNotFoundException` for Jackson classes.

**Cause**: Spring Boot 4.0 includes Jackson 3.0 (`tools.jackson.*`), but code still uses Jackson 2.x imports (`com.fasterxml.jackson.*`).

**Resolution**: Run the `mob-jackson-upgrade` skill to handle the Jackson 2.x → 3.0 migration.
