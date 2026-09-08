---
name: mob-springboot-kafka-upgrade
description: Migrate Kafka integration code for Spring Boot 4.0 compatibility
userInvocable: true
---

# Spring Boot 4.0 Kafka Migration Skill

This skill upgrades Spring Boot 3.x Kafka-related code to be compatible with Spring Boot 4.0.x. It should be applied AFTER the main Spring Boot 4 upgrade has been completed.

## Key Changes

### 1. Health Indicator Package Migration
Spring Boot 4 moved health-related classes from `spring-boot-actuate` to `spring-boot`.

**Imports to update:**
- `org.springframework.boot.actuate.health.Health` → `org.springframework.boot.health.contributor.Health`
- `org.springframework.boot.actuate.health.HealthIndicator` → `org.springframework.boot.health.contributor.HealthIndicator`

**mobile.de-specific health indicators:**
- `de.mobile.spring.boot.starter.metrics.health.MobileHealthIndicator` → `de.mobile.spring.boot.starter.metrics.health.ReactiveMobileHealthIndicator`

### 2. Reactive Health Check Migration
Health check methods must now return reactive types instead of blocking types.

**Pattern:**
```java
// Before (Spring Boot 3.x)
public Health mobileHealth() {
    return Optional
        .ofNullable(someCheck)
        .map(x -> Health.down().withDetails(...).build())
        .orElseGet(() -> Health.up().withDetails(...).build());
}

// After (Spring Boot 4.x)
public Mono<Health> mobileHealth() {
    return Mono.just(Optional
        .ofNullable(someCheck)
        .map(x -> Health.down().withDetails(...).build())
        .orElseGet(() -> Health.up().withDetails(...).build()));
}
```

**Required import:**
- Add: `import reactor.core.publisher.Mono;`

### 3. KafkaTemplate Reuse in Health Checks
Avoid creating new KafkaTemplate instances on every health check invocation.

**Pattern:**
```java
// Before
@Bean("kafkaHealthCheck")
public HealthIndicator kafkaHealthCheck(ProducerFactory<String, String> myProducerFactory,
                                        @Value("${spring.application.name}") String applicationName) {
    return () -> {
        try {
            new KafkaTemplate<>(myProducerFactory)  // Creates new instance every check
                    .send(new ProducerRecord<>("heartbeat", applicationName, "ping"))
                    .get(3L, TimeUnit.SECONDS);
            return Health.up().build();
        } catch (Exception e) {
            return Health.down(e).build();
        }
    };
}

// After
@Bean("kafkaHealthCheck")
public HealthIndicator kafkaHealthCheck(ProducerFactory<String, String> myProducerFactory,
                                        @Value("${spring.application.name}") String applicationName) {
    final KafkaTemplate<String, String> kafkaTemplate = new KafkaTemplate<>(myProducerFactory);
    return () -> {
        try {
            kafkaTemplate  // Reuse same instance
                    .send(new ProducerRecord<>("heartbeat", applicationName, "ping"))
                    .get(3L, TimeUnit.SECONDS);
            return Health.up().build();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            return Health.down(e).build();
        } catch (Exception e) {
            return Health.down(e).build();
        }
    };
}
```

### 4. Test Configuration Updates

**@EmbeddedKafka annotation changes:**
- Remove the `kraft = true` parameter (no longer needed/supported)
- Add `@AutoConfigureWebTestClient` annotation to test classes using reactive endpoints

**Pattern:**
```java
// Before
@EmbeddedKafka(
    partitions = 1,
    controlledShutdown = true,
    topics = {"heartbeat", "some-topic"},
    brokerProperties = "log.dir=target/embedded-kafka",
    kraft = true)  // Remove this
@Slf4j
public class KafkaTest extends AbstractIntegrationTest {
    // ...
}

// After
@EmbeddedKafka(
    partitions = 1,
    controlledShutdown = true,
    topics = {"heartbeat", "some-topic"},
    brokerProperties = "log.dir=target/embedded-kafka")  // kraft parameter removed
@AutoConfigureWebTestClient  // Add this for reactive tests
@Slf4j
public class KafkaTest extends AbstractIntegrationTest {
    // ...
}
```

**Required import:**
- Add: `import org.springframework.boot.webtestclient.autoconfigure.AutoConfigureWebTestClient;`

## Migration Steps

When invoked, this skill will:

1. **Scan for Kafka-related files:**
   - Find all Java files that import Kafka or Spring Kafka classes
   - Focus on configuration classes, consumers, producers, and health checks

2. **Update health indicator imports:**
   - Replace `org.springframework.boot.actuate.health.*` with `org.springframework.boot.health.contributor.*`
   - Replace `MobileHealthIndicator` with `ReactiveMobileHealthIndicator`

3. **Convert health check methods to reactive:**
   - Change return type from `Health` to `Mono<Health>`
   - Wrap existing logic in `Mono.just()`
   - Add `reactor.core.publisher.Mono` import

4. **Optimize KafkaTemplate usage:**
   - Extract KafkaTemplate creation outside of health check lambda
   - Declare as `final` field to enable reuse

5. **Update test files:**
   - Remove `kraft = true` from `@EmbeddedKafka` annotations
   - Add `@AutoConfigureWebTestClient` to test classes with reactive endpoints

6. **Verify changes:**
   - Compile the project to ensure no syntax errors
   - Run Kafka-related tests to verify functionality

## Files Typically Affected

- `**/config/*Kafka*.java` - Configuration classes
- `**/kafka/*Consumer*.java` - Consumer implementations
- `**/kafka/*Producer*.java` - Producer implementations
- `**/*HealthIndicator*.java` - Health check implementations
- `**/integration/*Kafka*Test.java` - Integration tests

## Prerequisites

- Spring Boot 4.0.x upgrade must be completed first (use `mob-springboot-upgrade` skill)
- Jackson 3.x upgrade should be completed (imports may reference Jackson 2 or 3)
- Project must compile with Spring Boot 4 dependencies

## Notes

- This skill focuses ONLY on Kafka-related Spring Boot 4 migration changes
- Jackson migration is handled separately by `mob-jackson-upgrade` skill
- General Spring Boot 4 changes are handled by `mob-springboot-upgrade` skill
- Health checks now use reactive patterns - ensure reactor-core is on the classpath
- The mobile.de starter for metrics must support `ReactiveMobileHealthIndicator` interface

## Related Skills

- `mob-springboot-upgrade` - Main Spring Boot 3.x to 4.0 migration
- `mob-jackson-upgrade` - Jackson 2 to 3 migration (often done alongside)
