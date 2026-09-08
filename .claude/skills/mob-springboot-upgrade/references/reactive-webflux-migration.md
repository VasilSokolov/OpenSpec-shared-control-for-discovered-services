# Spring Boot 4.0 Reactive WebFlux Migration - Lessons from notification-inbound-service

## Overview

This document captures lessons learned from migrating a reactive Spring Boot application (notification-inbound-service) from 3.5.x to 4.0.x. This was a WebFlux-based application using mobile.de starters.

## Key Migration Findings

### 1. Jackson 3.0 Migration Required

**Impact**: HIGH - Separate migration required

**Discovery**: Spring Boot 4.0 upgrades to Jackson 3.0, which uses a different package structure (`com.fasterxml.jackson` → `tools.jackson`).

**Migration Action**: Use the separate `mob-jackson-upgrade` skill to handle this migration:
```bash
# Check if Jackson migration is needed
grep -r "import com.fasterxml.jackson" --include="*.java" src/
```

**If Jackson 2.x imports are found**, invoke the `mob-jackson-upgrade` skill to handle the migration separately.

**Files Changed in notification-inbound-service**:
- `Application.java` - Jackson imports updated
- `BatchWebhookController.java` - Jackson imports updated
- `RemoteNotificationCenter.java` - Jackson imports updated

**Note**: The Jackson v3 migration is a separate concern from Spring Boot 4.0 migration and should be handled by the dedicated skill.

### 2. Logging and Metrics Dependency Changes for Reactive Apps (BOM 4.0.5+)

**Discovery**: As of `mobile-spring-boot-bom` 4.0.5, the WebFlux-specific starters for log4j2 and metrics have been removed. They must be replaced with the regular (non-webflux) starters.

#### Replace mobile-log4j2-webflux-spring-boot-starter

**Change**: Replace `mobile-log4j2-webflux-spring-boot-starter` with `mobile-log4j2-spring-boot-starter`.

**Before**:
```xml
<dependency>
    <groupId>de.mobile.spring.boot.starter</groupId>
    <artifactId>mobile-log4j2-webflux-spring-boot-starter</artifactId>
    <exclusions>
        <exclusion>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-tomcat</artifactId>
        </exclusion>
    </exclusions>
</dependency>
```

**After**:
```xml
<dependency>
    <groupId>de.mobile.spring.boot.starter</groupId>
    <artifactId>mobile-log4j2-spring-boot-starter</artifactId>
</dependency>
```

#### Replace mobile-metrics-webflux-spring-boot-starter

**Change**: Replace `mobile-metrics-webflux-spring-boot-starter` with `mobile-metrics-spring-boot-starter`.

**Before**:
```xml
<dependency>
    <groupId>de.mobile.spring.boot.starter</groupId>
    <artifactId>mobile-metrics-webflux-spring-boot-starter</artifactId>
</dependency>
```

**After**:
```xml
<dependency>
    <groupId>de.mobile.spring.boot.starter</groupId>
    <artifactId>mobile-metrics-spring-boot-starter</artifactId>
</dependency>
```

**Exception**: `mobile-swagger-webflux-spring-boot-starter` is **NOT affected** — it requires a distinct dependency set for WebFlux and remains unchanged.

#### Remove mobile-logback-spring-boot-starter from Tests

**Change**: The `mobile-logback-spring-boot-starter` dependency used for test logging is no longer needed.

**Before**:
```xml
<!-- Needed for defining where to store the log file 'test.log' -->
<dependency>
    <groupId>de.mobile.spring.boot.starter</groupId>
    <artifactId>mobile-logback-spring-boot-starter</artifactId>
</dependency>
```

**After**: Remove this dependency. Instead, use programmatic log appenders for tests.

#### Update Test Logging Approach

**Impact**: Tests that read log files must be refactored.

Replace file-based logging with an in-memory `TestLogAppender`. See `reactive-webflux-test-logging.md` for the full before/after implementation and setup instructions.

### 3. Graphite Metrics No Longer Supported (BOM 4.0.5+)

**Impact**: HIGH - Graphite metrics must be migrated to Prometheus Pushgateway

**Discovery**: `mobile-spring-boot-bom` 4.0.5 dropped support for Graphite metrics entirely. Remove all Graphite-related dependencies and configuration.

**Migration Action**: Remove Graphite dependency and configuration:

```xml
<!-- REMOVE -->
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-graphite</artifactId>
</dependency>
```

```yaml
# REMOVE all Graphite properties:
metrics:
  graphite:
    host: graphite.mobile.rz
    port: 2003
    delay: 60000
    enabled: false

management:
  metrics:
    export:
      graphite:
        enabled: true
```

**Replacement — Prometheus Pushgateway**:

For batch jobs and short-lived processes that previously used Graphite, use Prometheus Pushgateway. It has been added to mobile.de infrastructure. No extra dependency is needed when `mobile-metrics-spring-boot-starter` is included. Enable by adding the address property:

```yaml
metrics:
  prometheus:
    pushgateway:
      address: <pushgateway-host>:<port>
```

The presence of `metrics.prometheus.pushgateway.address` triggers Pushgateway autoconfiguration automatically.

### 4. Servlet Dependency Cleanup (CRITICAL for Pure Reactive Apps)

**Impact**: HIGH - Architecture and runtime behavior

**Discovery**: Many Spring Boot 3.x reactive applications included `spring-boot-starter-web` with extensive exclusions to prevent servlet container initialization. In Spring Boot 4.0, this pattern can be simplified or removed.

**Common Pattern in Spring Boot 3.x**:
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
    <exclusions>
        <exclusion>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-logging</artifactId>
        </exclusion>
        <exclusion>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-tomcat</artifactId>
        </exclusion>
        <exclusion>
            <groupId>org.springframework</groupId>
            <artifactId>spring-webmvc</artifactId>
        </exclusion>
    </exclusions>
</dependency>
```

**Why This Was Done**: 
- To get some Spring MVC-related annotations or utilities
- To prevent Tomcat container from starting
- Historical reasons from mixed servlet/reactive architectures

**Spring Boot 4.0 Approach**: Remove `spring-boot-starter-web` entirely for pure reactive apps.

```xml
<!-- REMOVE ENTIRELY -->
<!-- <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
    ...
</dependency> -->

<!-- Keep only reactive dependencies -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-webflux</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-reactor-netty</artifactId>
</dependency>
```

**Detection**:
```bash
# Check if app has spring-boot-starter-web
grep -A 20 "spring-boot-starter-web" pom.xml

# Check for servlet contamination
mvn dependency:tree | grep -i servlet
mvn dependency:tree | grep -i tomcat
```

**Benefits of Removal**:
1. **Cleaner dependencies**: No servlet APIs in classpath
2. **Smaller artifact size**: No servlet container JARs
3. **Faster startup**: No servlet auto-configuration processing
4. **Clear architecture**: Pure reactive stack
5. **Prevents accidents**: Can't accidentally use blocking servlet APIs

**Enforcing Pure Reactive** (recommended):
Add Maven Enforcer Plugin to ban servlet dependencies:

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-enforcer-plugin</artifactId>
    <executions>
        <execution>
            <id>ban-servlet-dependencies</id>
            <phase>test-compile</phase>
            <goals>
                <goal>enforce</goal>
            </goals>
            <configuration>
                <rules>
                    <bannedDependencies>
                        <excludes>
                            <exclude>javax.servlet:javax.servlet-api</exclude>
                            <exclude>jakarta.servlet:jakarta.servlet-api</exclude>
                            <exclude>org.apache.tomcat.embed:tomcat-embed-core</exclude>
                        </excludes>
                        <message>
                            This is a pure reactive application. Servlet dependencies are not allowed.
                            Use WebFlux and reactive starters only.
                        </message>
                    </bannedDependencies>
                </rules>
            </configuration>
        </execution>
    </executions>
</plugin>
```

**When NOT to Remove**:
- If you have a mixed servlet/reactive application (e.g., some endpoints are blocking, some reactive)
- If you're using libraries that specifically require servlet APIs
- If you're gradually migrating from servlet to reactive

**Verification After Removal**:
```bash
# Check dependency tree has no servlet references
mvn dependency:tree | grep servlet
# Should return nothing

# Start application and verify Netty is used (not Tomcat)
# Log should show: "Netty started on port(s): 8080"
# Should NOT show: "Tomcat started on port(s): 8080"
```

### 5. Spring Security Auto-configuration Changes

**Discovery**: Spring Boot 4.0's security auto-configuration no longer requires explicit exclusion in many cases.

**Before**:
```java
@SpringBootApplication(exclude = {SecurityAutoConfiguration.class})
@EnableSwaggerOnRoot
@EnableScheduling
public class Application {
    // ...
}
```

**After**:
```java
@SpringBootApplication
@EnableSwaggerOnRoot
@EnableScheduling
public class Application {
    // ...
}
```

**Related Dependency Removal**:
```xml
<!-- REMOVE if not actually using Spring Security -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>
```

**Note**: If you were excluding `SecurityAutoConfiguration` and not using Spring Security, you can remove both the exclusion and the dependency.

### 5. Reactor Core Micrometer Version Update

**Discovery**: The `reactor-core-micrometer` dependency version 1.2.12 (used in SB 3.5.x) has compatibility issues with Spring Boot 4.0's Micrometer 2.x.

**Before (SB 3.5.x)**:
```xml
<dependency>
    <groupId>io.projectreactor</groupId>
    <artifactId>reactor-core-micrometer</artifactId>
    <version>1.2.12</version>
</dependency>
```

**After (SB 4.0.x)**:
```xml
<dependency>
    <groupId>io.projectreactor</groupId>
    <artifactId>reactor-core-micrometer</artifactId>
    <version>1.2.18</version>  <!-- minimum version for SB 4.0 compatibility -->
</dependency>
```

**Version Compatibility**:
- **1.2.12 and earlier**: Compatible with Spring Boot 3.x (Micrometer 1.x)
- **1.2.18+**: Compatible with Spring Boot 4.0.x (Micrometer 2.x)
- **3.x**: Future major version for full Spring Boot 4.0 support (not yet stable)

**Why This Matters**:
- Reactor metrics integration with Micrometer changed in version 2.x
- Using old version may cause metrics to not be collected or reported incorrectly
- New version provides better integration with Spring Boot 4.0's observability stack

**Verification**:
```bash
# Check current version
grep -A 2 "reactor-core-micrometer" pom.xml
```

**Note**: Keep monitoring for version 3.x release for long-term compatibility.

### 6. Health Endpoint Configuration for Reactive Apps

**Discovery**: Initial attempts to expose health details required explicit configuration, but this was eventually removed.

**Initial Addition (later removed)**:
```yaml
management:
  endpoint:
    health:
      show-details: always
      show-components: always
  endpoints:
    web:
      exposure:
        include: health,metrics,info
  health:
    ping:
      enabled: true
    diskspace:
      enabled: true
    livenessstate:
      enabled: true
    readinessstate:
      enabled: true
    kafka:
      enabled: true
  ssl:
    health:
      enabled: true
```

**Final State**: Removed all management configuration, relying on mobile.de starter defaults.

**Lesson**: The mobile-metrics-webflux-spring-boot-starter 4.0.x provides sensible defaults for health indicators. Only add explicit configuration if you need to override defaults.

### 7. Configuration File Cleanup

**Discovery**: Several configuration properties were experimented with and ultimately removed.

**Properties Removed During Migration**:
```yaml
# Commented out - not needed in SB 4.0
#  jackson:
#    default-property-inclusion: non_null

# Removed - handled by mobile starter defaults
management:
  metrics:
    export:
      graphite:
        enabled: true

metrics:
  graphite:
    host: graphite.mobile.rz
    port: 2003
    delay: 60000
    enabled: false
```

**Lesson**: Start with minimal configuration and only add what's explicitly needed. Mobile.de starters provide sensible defaults.

## Reactive WebFlux-Specific Checklist

Use this checklist for reactive Spring Boot applications:

- [ ] **Jackson 3.0 Migration** (use separate `mob-jackson-upgrade` skill)
  - [ ] Checked for Jackson 2.x imports: `grep -r "import com.fasterxml.jackson" --include="*.java" src/`
  - [ ] If found, run `mob-jackson-upgrade` skill to handle migration
  - [ ] Tested JSON serialization/deserialization after Jackson migration
  
- [ ] **Logging Dependencies**
  - [ ] Replaced `mobile-log4j2-webflux-spring-boot-starter` → `mobile-log4j2-spring-boot-starter`
  - [ ] Replaced `mobile-metrics-webflux-spring-boot-starter` → `mobile-metrics-spring-boot-starter`
  - [ ] `mobile-swagger-webflux-spring-boot-starter` left unchanged (not affected)
  - [ ] Removed `mobile-logback-spring-boot-starter` from test dependencies
  - [ ] Created `TestLogAppender` for log assertions
  - [ ] Refactored test classes using file-based log reading
  - [ ] Removed `test.logdir` system property configuration

- [ ] **Metrics Configuration**
  - [ ] Removed `micrometer-registry-graphite` dependency (Graphite no longer supported in BOM 4.0.5+)
  - [ ] Removed all `metrics.graphite.*` configuration properties
  - [ ] Removed `management.metrics.export.graphite.*` properties
  - [ ] If batch job / short-lived process: configured Prometheus Pushgateway via `metrics.prometheus.pushgateway.address`
  - [ ] Verified metrics are still being exported
  
- [ ] **Spring Security**
  - [ ] Removed `SecurityAutoConfiguration` exclusion if not using security
  - [ ] Removed `spring-boot-starter-security` if not needed
  
- [ ] **Reactor Dependencies**
  - [ ] Updated `reactor-core-micrometer` to 1.2.18+ or 3.x
  - [ ] Verified reactive streams work correctly
  
- [ ] **Configuration Cleanup**
  - [ ] Removed unnecessary management.* properties
  - [ ] Verified application starts with minimal configuration
  - [ ] Tested health endpoints work correctly

## Common Reactive WebFlux Issues

### Issue: Jackson Deserialization Fails

**Symptom**: JSON deserialization throws `ClassNotFoundException` for Jackson classes.

**Cause**: Jackson 2.x imports not updated to Jackson 3.0.

**Resolution**: Use the `mob-jackson-upgrade` skill to handle the Jackson 2.x → 3.0 migration.

### Issue: Tests Fail with Log File Not Found

**Symptom**: Tests fail with `FileNotFoundException: test.log`

**Cause**: Tests rely on file-based logging which is no longer configured.

**Resolution**: Implement `TestLogAppender` pattern shown above.

### Issue: Metrics Not Exported to Graphite

**Symptom**: Application starts but metrics aren't sent to Graphite.

**Cause**: `micrometer-registry-graphite` not explicitly included.

**Resolution**: Add `micrometer-registry-graphite` dependency.

### Issue: WebClient Beans Not Found

**Symptom**: `@Autowired WebClient` fails with no qualifying bean.

**Cause**: `mobile-http-client-spring-boot-starter` not included.

**Resolution**: Add `mobile-http-client-spring-boot-starter` as documented in main migration guide.

## WebFlux Application Pattern

See `reactive-webflux-migration-example.md` for a complete before/after `pom.xml` based on a real migration (notification-inbound-service).

## Summary

Key takeaways for reactive WebFlux migrations to Spring Boot 4.0:

### Critical Changes (Must Do)

1. **Remove servlet contamination** 
   - Delete `spring-boot-starter-web` with exclusions
   - Verify pure reactive stack with `mvn dependency:tree`
   - Consider adding maven-enforcer-plugin to ban servlet JARs

2. **Replace WebFlux-specific starters (BOM 4.0.5+)**
   - Replace `mobile-metrics-webflux-spring-boot-starter` → `mobile-metrics-spring-boot-starter`
   - Replace `mobile-log4j2-webflux-spring-boot-starter` → `mobile-log4j2-spring-boot-starter`
   - Keep `mobile-swagger-webflux-spring-boot-starter` unchanged
   - Remove `micrometer-registry-graphite` (Graphite no longer supported)
   - Remove all `metrics.graphite.*` configuration properties
   - For batch jobs needing metrics: add `metrics.prometheus.pushgateway.address`

3. **Update test logging**
   - Delete `mobile-logback-spring-boot-starter` from tests
   - Implement `TestLogAppender` pattern for test log assertions

4. **Update reactive dependencies**
   - Update `reactor-core-micrometer` to 1.2.18+ (minimum)
   - Add `spring-boot-webtestclient` for testing
   - Add `mobile-http-client-spring-boot-starter` if needed

### Important Changes

5. **Jackson 3.0 migration** 
   - Spring Boot 4.0 includes Jackson 3.0 (separate package structure)
   - Use `mob-jackson-upgrade` skill for this migration
   - All `com.fasterxml..jackson` imports become `tools.jackson`

6. **Build configuration**
   - Add `<parameters>true</parameters>` to maven-compiler-plugin
   - Update Spring Boot parent to 4.0.x
   - Update mobile.de BOM to 4.0.x

### Nice to Have

7. **Configuration simplification**
   - Remove explicit management.* configuration

8. **Security cleanup**
   - Remove `SecurityAutoConfiguration` exclusion if not using security
   - Remove `spring-boot-starter-security` if not needed

### Migration Sequence

**Recommended order** for reactive WebFlux applications:

1. Update Java to 21
2. Update Spring Boot to 4.0.x and mobile.de BOM to 4.0.x
3. Clean up servlet dependencies (remove spring-boot-starter-web)
4. Update reactive starters (metrics, remove logging)
5. Add explicit dependencies (graphite, http-client, webtestclient)
6. Update reactor-core-micrometer version
7. Refactor test logging (TestLogAppender pattern)
8. Build and fix compilation errors
9. **Separately**: Run `mob-jackson-upgrade` skill for Jackson 2.x → 3.0
10. Validate application and tests

### Common Pitfalls

- **Test logging breaks**: File-based logging won't work, need TestLogAppender
- **Graphite removed**: BOM 4.0.5+ does not support Graphite at all — migrate to Pushgateway for batch jobs
- **WebFlux starters replaced**: Use `mobile-metrics-spring-boot-starter` and `mobile-log4j2-spring-boot-starter` (not webflux variants)
- **Swagger exception**: `mobile-swagger-webflux-spring-boot-starter` still needed for WebFlux Swagger — do not replace it
- **Servlet contamination**: Pure reactive apps should have zero servlet dependencies

These findings complement the main Spring Boot 4.0 migration guide and are specific to reactive WebFlux applications using mobile.de starters.
