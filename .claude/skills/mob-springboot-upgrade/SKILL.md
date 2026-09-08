---
name: mob-springboot-upgrade
description: Upgrade Spring Boot applications from 3.5.x to 4.0.x, including mobile.de-specific starters
disable-model-invocation: true
---

You are a Spring Boot 4.0 upgrade expert helping users upgrade their applications from Spring Boot 3.5.x to 4.0.x, with specialized knowledge of mobile.de's internal spring-boot-starter libraries.

**IMPORTANT**: This skill handles Spring Boot framework migration only. Spring Boot 4.0 includes Jackson 3.0 and may have Lombok compatibility issues related to Jackson. The Spring Boot upgrade can be completed first, but compilation may fail due to Jackson/Lombok issues. These require separate migration using the `mob-jackson-upgrade` skill AFTER completing the Spring Boot upgrade.

**Latest Versions (as of 2026-06-16)**:
- Spring Boot: 4.0.6
- mobile.de BOM: 4.0.5

## Core Responsibilities

When invoked, you should:

1. **Analyze the current Spring Boot setup**:
   - Identify Spring Boot version in `pom.xml` or `build.gradle`
   - Find mobile.de starter dependencies (`de.mobile.spring.boot.starter`)
   - Check Java version requirement
   - Identify deprecated Spring Boot 3.x APIs in use
   - Find Jakarta EE dependencies that may need updates
   - Check for removed or relocated classes
   - Identify configuration properties that changed

2. **Review mobile.de-specific requirements**:
   - Check if project uses `mobile-spring-boot-starter-bom`
   - Identify which mobile.de starters are in use
   - Review mobile.de-specific migration requirements from MIGRATION_GUIDE.md
   - Check for HTTP client autoconfiguration dependencies
   - Verify domain starter test container usage

3. **Create a comprehensive migration plan**:
   - Java version upgrade to 21+ (minimum requirement)
   - Spring Boot parent/BOM version update to 4.0.x
   - mobile.de BOM update to 4.0.x
   - Dependency updates and removals
   - Code changes for deprecated/removed APIs
   - Configuration property updates
   - Test updates
   - Build configuration changes

4. **Execute the migration systematically**:
   - Update Java version in build files
   - Update Spring Boot parent version
   - Update mobile.de BOM version
   - Add explicit dependencies for previously transitive ones
   - Update deprecated Spring Boot APIs
   - Migrate configuration properties
   - Update test configurations
   - Fix compilation errors
   - Update CI/CD configurations

5. **Validate the migration**:
   - Verify code compiles
   - Run all tests
   - Check application starts correctly
   - Verify actuator endpoints work
   - Test key application functionality
   - Review deprecation warnings

## Approach

### Phase 1: Discovery and Assessment

#### Step 1: Identify Current Versions
```bash
# Check Java version
cat .java-version
# or in pom.xml
grep -A 1 "<java.version>" pom.xml

# Check Spring Boot version
grep -A 2 "spring-boot-starter-parent" pom.xml
# or
grep "org.springframework.boot" build.gradle

# Check mobile.de starter BOM version
grep -A 4 "mobile-spring-boot-starter-bom" pom.xml
```

#### Step 2: Identify mobile.de Starters in Use
```bash
# Find all mobile.de starter dependencies
grep "de.mobile.spring.boot.starter" pom.xml
# or
grep "de.mobile.spring.boot.starter" build.gradle
```

Common mobile.de starters:
- `mobile-domain-spring-boot-starter` - MySQL database setup
- `mobile-metrics-spring-boot-starter` - Metrics and health checks (servlet and reactive)
- `mobile-log4j2-spring-boot-starter` - Log4j2 logging (servlet and reactive)
- `mobile-logback-spring-boot-starter` - Logback logging
- `mobile-swagger-spring-boot-starter` - Swagger UI (servlet)
- `mobile-swagger-webflux-spring-boot-starter` - Swagger UI (reactive)
- `mobile-http-client-spring-boot-starter` - WebClient/RestClient with proxy
- `mobile-gcp-spring-boot-starter` - GCP authentication
- `mobile-jobs-spring-boot-starter` - Websocket jobs
- `mobile-test-spring-boot-starter` - Integration test utilities
- `mobile-embedmongo-spring-boot-starter` - Embedded MongoDB for tests
- `mobile-dropwizard-metrics-spring-boot-starter` - Legacy Dropwizard metrics (avoid for new projects)

#### Step 2a: Detect Reactive vs Servlet Application Type

**CRITICAL**: Reactive (WebFlux) applications have different migration requirements than servlet-based applications.

**Detect Reactive Application**:
```bash
# Check for WebFlux dependency
grep "spring-boot-starter-webflux" pom.xml

# Check for reactive starters
grep -E "(webflux|reactive)" pom.xml

# Check for Reactor dependencies
grep "reactor-" pom.xml

# Check for reactive mobile.de starters (old names, pre-BOM 4.0.5)
grep -E "mobile-(metrics|log4j2)-webflux" pom.xml
```

**Indicators of a Reactive Application**:
- Has `spring-boot-starter-webflux`
- Has `spring-boot-starter-reactor-netty`
- Has `reactor-core`, `reactor-test`, or `reactor-core-micrometer` dependencies
- Code uses `Mono`, `Flux`, `@RestController` with reactive types

**Indicators of a Servlet Application**:
- Has `spring-boot-starter-web` (without webflux)
- Has `spring-boot-starter-tomcat`
- Code uses traditional servlet patterns

**If Reactive Application Detected**:
- Refer to `references/reactive-webflux-migration.md` for reactive-specific guidance
- Key differences: starter replacements, metrics configuration, test patterns
- Must replace `mobile-log4j2-webflux-spring-boot-starter` → `mobile-log4j2-spring-boot-starter`
- Must replace `mobile-metrics-webflux-spring-boot-starter` → `mobile-metrics-spring-boot-starter`
- **Exception**: `mobile-swagger-webflux-spring-boot-starter` is NOT affected and stays as-is
- May need to refactor test logging from file-based to in-memory

#### Step 3: Find Deprecated API Usage
```bash
# Search for common deprecated patterns
grep -r "WebSecurityConfigurerAdapter" --include="*.java" .
grep -r "AbstractSecurityWebApplicationInitializer" --include="*.java" .
grep -r "spring.data.redis.repositories.enabled" src/main/resources/
grep -r "spring.jpa.hibernate.use-new-id-generator-mappings" src/main/resources/

# Check for removed Spring Security methods
grep -r "antMatchers" --include="*.java" .
grep -r "mvcMatchers" --include="*.java" .
grep -r "regexMatchers" --include="*.java" .
```

#### Step 4: Review Configuration Files
```bash
# Find application properties/yaml files
find . -name "application*.properties" -o -name "application*.yml" -o -name "application*.yaml"

# Check for deprecated properties
grep -r "spring.redis.repositories.enabled" src/main/resources/
grep -r "spring.jpa.hibernate.use-new-id-generator-mappings" src/main/resources/
grep -r "management.metrics.export" src/main/resources/
```

### Phase 2: Planning

Create a checklist based on findings:

1. **Java Version**: Current vs. Target (must be 21+)
2. **Spring Boot Version**: Current (3.5.x) → Target (4.0.x)
3. **mobile.de BOM Version**: Current (3.5.x) → Target (4.0.x)
4. **Dependencies to Update**: List all Spring and mobile.de dependencies
5. **Dependencies to Add**: HTTP client if using metrics starter
6. **Dependencies to Remove**: Deprecated or replaced dependencies
7. **Code Changes**: List files with deprecated API usage
8. **Configuration Changes**: Properties that need updating
9. **Test Changes**: Test-specific dependencies and configurations

### Phase 3: Execution

#### Step 1: Update Java Version

**In pom.xml**:
```xml
<properties>
    <java.version>21</java.version>
</properties>

<!-- Also update compiler plugin if explicitly configured -->
<plugin>
    <artifactId>maven-compiler-plugin</artifactId>
    <configuration>
        <source>21</source>
        <target>21</target>
    </configuration>
</plugin>
```

**In build.gradle**:
```groovy
java {
    sourceCompatibility = JavaVersion.VERSION_21
    targetCompatibility = JavaVersion.VERSION_21
}
```

**In .java-version**:
```
21
```

#### Step 2: Update Spring Boot Parent Version

**Maven (pom.xml)**:
```xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>4.0.6</version>  <!-- or latest 4.0.x -->
</parent>
```

**Gradle (build.gradle)**:
```groovy
plugins {
    id 'org.springframework.boot' version '4.0.6'
    id 'io.spring.dependency-management' version '1.1.7'
}
```

#### Step 3: Update mobile.de BOM Version

**Maven (pom.xml)**:
```xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>de.mobile.spring.boot.starter</groupId>
            <artifactId>mobile-spring-boot-starter-bom</artifactId>
            <version>4.0.5</version>  <!-- or latest 4.0.x -->
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

**Gradle (build.gradle)**:
```groovy
dependencyManagement {
    imports {
        mavenBom 'de.mobile.spring.boot.starter:mobile-spring-boot-starter-bom:4.0.5'
    }
}
```

#### Step 4: Replace WebFlux Starters (mobile.de-specific, BOM 4.0.5+)

**NOTE**: As of `mobile-spring-boot-bom` 4.0.5, the WebFlux variants of the metrics and log4j2 starters have been removed. Replace them with the regular starters:

| Old (remove) | New (add) |
|---|---|
| `mobile-log4j2-webflux-spring-boot-starter` | `mobile-log4j2-spring-boot-starter` |
| `mobile-metrics-webflux-spring-boot-starter` | `mobile-metrics-spring-boot-starter` |

**Exception**: `mobile-swagger-webflux-spring-boot-starter` is NOT affected — it requires a different set of dependencies for WebFlux and must remain as-is.

Detection:
```bash
grep -E "mobile-(log4j2|metrics)-webflux-spring-boot-starter" pom.xml
```

#### Step 4a: Add HTTP Client Dependency (mobile.de-specific)

**NOTE**: In Spring Boot 4.0, the `mobile-http-client-spring-boot-starter` dependency was removed from metrics starters.

**However**, many applications do NOT need this dependency explicitly. Only add it if your application:
- Uses `mobile-metrics-spring-boot-starter`, `mobile-metrics-webflux-spring-boot-starter`, or `mobile-dropwizard-metrics-spring-boot-starter`
- AND relies on HTTP client autoconfiguration (WebClient/RestClient with proxy support)
- AND uses `@Autowired WebClient` or `@Autowired RestClient` in the code

Check your codebase first:
```bash
grep -r "@Autowired.*WebClient" --include="*.java" src/
grep -r "@Autowired.*RestClient" --include="*.java" src/
```

If found, then explicitly add:

```xml
<dependency>
    <groupId>de.mobile.spring.boot.starter</groupId>
    <artifactId>mobile-http-client-spring-boot-starter</artifactId>
</dependency>
```

See `references/migration-patterns.md` for the Gradle equivalent.

#### Step 4b: Configure Prometheus Pushgateway (if applicable)

**New in BOM 4.0.5**: Graphite metrics are no longer supported. For batch jobs or short-lived processes that need to publish metrics without Graphite, use **Prometheus Pushgateway** instead.

Pushgateway support is configured via a single property — no extra dependency needed if `mobile-metrics-spring-boot-starter` is already included:

```yaml
metrics:
  prometheus:
    pushgateway:
      address: <pushgateway-host>:<port>
```

The presence of this property triggers Pushgateway autoconfiguration automatically.

#### Step 5: Add Domain Test Container Dependency (mobile.de-specific)

If you use `mobile-domain-spring-boot-starter` AND your tests rely on the embedded MySQL test container, add the test-jar. See `references/migration-patterns.md` (Pattern 3) for Maven and Gradle snippets.

#### Step 5a: Update Health Package (CRITICAL for Spring Boot 4.0)

**CRITICAL BREAKING CHANGE**: Health classes moved to a new package. No new dependency needed — only import changes.

```java
// Before
import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.HealthIndicator;

// After
import org.springframework.boot.health.contributor.Health;
import org.springframework.boot.health.contributor.HealthIndicator;
```

```bash
grep -r "org.springframework.boot.actuate.health" src/ --include="*.java"
```

#### Step 6: Update Spring Security Configuration

Remove `extends WebSecurityConfigurerAdapter`, switch to a `@Bean SecurityFilterChain` method, replace `antMatchers()` with `requestMatchers()`, and use the lambda DSL style. See `references/springboot-4-breaking-changes.md` for before/after code examples.

#### Step 7: Update JPA/Hibernate Configuration

Remove `spring.jpa.hibernate.use-new-id-generator-mappings` and `spring.jpa.properties.hibernate.id.new_generator_mappings`. If using a custom physical naming strategy, update to `org.hibernate.boot.model.naming.CamelCaseToUnderscoresNamingStrategy`. Spring Boot 4.0 uses Hibernate 7 — run the full integration test suite to catch behavioral changes.

#### Step 8: Update Data Redis Configuration

Rename `spring.redis.repositories.enabled` → `spring.data.redis.repositories.enabled`.

#### Step 9: Update Actuator Configuration

Add health detail config if needed and update metrics export namespace (`management.metrics.export.{format}.*` → `management.{format}.metrics.export.*`). See `references/springboot-4-breaking-changes.md` for details.

#### Step 10: Update Bean Validation

Verify no `javax.validation.*` imports remain — all should be `jakarta.validation.*`. Spring Boot 4.0 requires Jakarta EE 10+.

#### Step 11: Update REST Client Usage

`RestTemplate` is not removed but `RestClient` is preferred. See `references/springboot-4-breaking-changes.md` for a `RestClient` example.

#### Step 12: Update Test Configuration

Ensure all tests use JUnit 5 annotations (`org.junit.jupiter.*`). Most MockMvc code continues to work unchanged.

#### Step 13: Update Build Plugins

Add `<parameters>true</parameters>` to `maven-compiler-plugin` (preserves method parameter names for Spring's reflection-based features). Ensure `maven-surefire-plugin` and `maven-failsafe-plugin` are at 3.5.2+. See `references/migration-patterns.md` for the full plugin configuration.

### Phase 4: Validation

```bash
# Verify no javax.* imports remain
grep -r "import javax\." --include="*.java" src/ | grep -v "annotation" | wc -l
# Should return 0

# Verify actuator health endpoint
curl http://localhost:8080/actuator/health
```

See `references/migration-checklist.md` for the full validation checklist.

## Critical Migration Points for mobile.de Projects

### 0. WebFlux Starter Replacement (BOM 4.0.5+)

`mobile-log4j2-webflux-spring-boot-starter` and `mobile-metrics-webflux-spring-boot-starter` were removed. Replace with:
- `mobile-log4j2-spring-boot-starter`
- `mobile-metrics-spring-boot-starter`

`mobile-swagger-webflux-spring-boot-starter` is **NOT affected**.

### 1. HTTP Client Dependency (CRITICAL)
The `mobile-http-client-spring-boot-starter` is NO LONGER included transitively through metrics starters.

**Detection**:
```bash
# Check if you're using WebClient or RestClient autowiring
grep -r "@Autowired.*WebClient" --include="*.java" .
grep -r "@Autowired.*RestClient" --include="*.java" .
grep -r "WebClient\.Builder" --include="*.java" .
grep -r "RestClient\.Builder" --include="*.java" .
```

**Action**: If found, explicitly add `mobile-http-client-spring-boot-starter` dependency.

### 2. Domain Test Container (CRITICAL for Tests)
If tests fail with MySQL container errors after migration:

**Detection**:
```bash
# Check if tests use embedded MySQL
grep -r "MySQLContainer" --include="*.java" src/test/
grep -r "@Testcontainers" --include="*.java" src/test/
grep -r "mobile-domain" src/test/
```

**Action**: Add test-jar dependency as shown in Step 5.

### 3. Java 21 Requirement
Spring Boot 4.0 requires Java 21 minimum.

**Verification**:
```bash
java -version  # Should show 21 or higher
cat .java-version  # Should be 21 or higher
```

### 4. Hibernate 7 Changes
Spring Boot 4.0 uses Hibernate 7 (upgrade from Hibernate 6).

**Common issues**:
- ID generation strategies may behave differently
- Some Hibernate-specific annotations changed
- Query result handling may differ

**Mitigation**: Run full integration test suite to catch behavioral changes.

## Common Migration Patterns

See `references/migration-patterns.md` for full before/after `pom.xml` examples covering:
- Pattern 1: Simple servlet web application
- Pattern 2: Reactive WebFlux application (also see `references/reactive-webflux-migration-example.md`)
- Pattern 3: Application with Domain (MySQL)

## Troubleshooting Guide

See `references/troubleshooting.md` for solutions to common issues:
- Compilation errors (Spring Security, health package, Hibernate, Jakarta)
- Test container errors (missing domain test-jar)
- Application startup failures
- WebClient/RestClient not autowiring
- Actuator 404s
- Test log file not found (reactive apps)
- Graphite metrics not exported
- Jackson deserialization failures

## Migration Checklist

See `references/migration-checklist.md` for the full standard and reactive checklists.

## Best Practices

- Use Spring Boot 4.0.6+ and mobile.de BOM 4.0.5+
- Java 21 required — verify before starting
- Update all `org.springframework.boot.actuate.health.*` imports to `org.springframework.boot.health.contributor.*`
- Only add `mobile-http-client-spring-boot-starter` if code actually autowires `WebClient`/`RestClient`
- Jackson/Lombok compilation errors are expected — run `mob-jackson-upgrade` skill separately after
- Always consult the official [mobile.de MIGRATION_GUIDE.md](https://github.mpi-internal.com/mobile-de/mobile-spring-boot-starter/blob/master/MIGRATION_GUIDE.md)
- Update Docker base images too
- Can migrate one module at a time in multi-module projects

## Success Criteria

Migration is complete when:
1. Java 21+, Spring Boot 4.0.6+, mobile.de BOM 4.0.5+
2. All health package imports updated to `org.springframework.boot.health.contributor.*`
3. All required dependencies added; HTTP client only if actually needed
4. Deprecated configuration properties removed; build config updated (`parameters=true`)

**Note**: Jackson/Lombok compilation errors are addressed separately with `mob-jackson-upgrade`.

## Additional Resources

- [Spring Boot 4.0 Migration Guide](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-4.0-Migration-Guide)
- [mobile.de MIGRATION_GUIDE.md](https://github.mpi-internal.com/mobile-de/mobile-spring-boot-starter/blob/master/MIGRATION_GUIDE.md)
- [mobile.de Spring Boot Starter README](https://github.mpi-internal.com/mobile-de/mobile-spring-boot-starter/blob/master/README.md)
- [Spring Security 7.0 Migration](https://docs.spring.io/spring-security/reference/migration-7/index.html)
- [Hibernate 7 Migration Guide](https://hibernate.org/orm/releases/7.0/)

When migration is complete, provide a summary of:
- Versions updated (Java, Spring Boot, mobile.de BOM)
- Dependencies added/removed
- Code changes made (files modified, key changes)
- Configuration changes
- Validation results (compilation, tests, startup)
