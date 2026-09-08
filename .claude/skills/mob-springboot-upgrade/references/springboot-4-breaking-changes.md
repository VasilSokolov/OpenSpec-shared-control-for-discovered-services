# Spring Boot 4.0 Breaking Changes Reference

## Overview

This document catalogs key breaking changes between Spring Boot 3.5.x and 4.0.x that affect migration.

## Java Requirements

### Minimum Java Version: 21

**Impact**: High - Blocks migration if not addressed

**Change**: Spring Boot 4.0 requires Java 21 as the minimum version (up from Java 17 in 3.x)

**Migration Action**:
- Update `.java-version` to 21
- Update `<java.version>` in pom.xml to 21
- Update compiler plugin configuration
- Update CI/CD pipelines to use Java 21
- Update Docker base images to Java 21

**Example**:
```xml
<properties>
    <java.version>21</java.version>
</properties>
```

## Spring Security Changes

### WebSecurityConfigurerAdapter Removed

**Impact**: High - Code changes required

**Change**: `WebSecurityConfigurerAdapter` is completely removed in Spring Security 7.0 (part of Spring Boot 4.0)

**Before**:
```java
@Configuration
@EnableWebSecurity
public class SecurityConfig extends WebSecurityConfigurerAdapter {
    
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http
            .authorizeRequests()
                .antMatchers("/public/**").permitAll()
                .anyRequest().authenticated();
    }
}
```

**After**:
```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(authz -> authz
                .requestMatchers("/public/**").permitAll()
                .anyRequest().authenticated()
            );
        return http.build();
    }
}
```

**Migration Actions**:
1. Remove `extends WebSecurityConfigurerAdapter`
2. Change method to return `SecurityFilterChain` with `@Bean`
3. Replace `authorizeRequests()` with `authorizeHttpRequests()`
4. Use lambda DSL style
5. Return `http.build()`

### antMatchers() Replaced with requestMatchers()

**Impact**: Medium - Simple find/replace

**Change**: `antMatchers()`, `mvcMatchers()`, and `regexMatchers()` are removed

**Before**:
```java
.authorizeRequests()
    .antMatchers("/api/public/**").permitAll()
    .mvcMatchers("/admin/**").hasRole("ADMIN")
    .regexMatchers("/user/.*").authenticated()
```

**After**:
```java
.authorizeHttpRequests(authz -> authz
    .requestMatchers("/api/public/**").permitAll()
    .requestMatchers("/admin/**").hasRole("ADMIN")
    .requestMatchers(RegexRequestMatcher.regexMatcher("/user/.*")).authenticated()
)
```

**Migration Actions**:
1. Replace `antMatchers()` with `requestMatchers()`
2. Replace `mvcMatchers()` with `requestMatchers()`
3. For regex patterns, use `RegexRequestMatcher.regexMatcher()`

### WebSecurityCustomizer Changes

**Before**:
```java
@Bean
public WebSecurityCustomizer webSecurityCustomizer() {
    return (web) -> web.ignoring().antMatchers("/resources/**");
}
```

**After**:
```java
@Bean
public WebSecurityCustomizer webSecurityCustomizer() {
    return (web) -> web.ignoring().requestMatchers("/resources/**");
}
```

## JPA/Hibernate Changes

### Hibernate 7 (from Hibernate 6)

**Impact**: Medium to High - Behavioral changes

**Changes**:
- ID generation strategies updated
- Query result handling changes
- Some APIs deprecated or removed
- Performance characteristics may differ

**Migration Actions**:
1. Test all database interactions thoroughly
2. Review custom Hibernate code
3. Update deprecated Hibernate APIs
4. Verify ID generation behavior

### Removed Property: use-new-id-generator-mappings

**Impact**: Low - Property removal

**Change**: Property `spring.jpa.hibernate.use-new-id-generator-mappings` is no longer recognized

**Migration Action**: Remove this property from `application.properties` or `application.yml`

```properties
# REMOVE:
spring.jpa.hibernate.use-new-id-generator-mappings=true
```

### Physical Naming Strategy Changes

**Impact**: Medium - Default behavior changed

**Before**:
```properties
spring.jpa.hibernate.naming.physical-strategy=org.springframework.boot.orm.jpa.hibernate.SpringPhysicalNamingStrategy
```

**After**:
```properties
spring.jpa.hibernate.naming.physical-strategy=org.hibernate.boot.model.naming.CamelCaseToUnderscoresNamingStrategy
```

## Data/Redis Changes

### Configuration Property Namespace Change

**Impact**: Low - Simple property rename

**Before**:
```properties
spring.redis.repositories.enabled=false
```

**After**:
```properties
spring.data.redis.repositories.enabled=false
```

## Actuator Changes

### Health Endpoint Details Configuration

**Impact**: Medium - May expose sensitive information if not configured

**Change**: Health endpoint detail visibility requires explicit configuration

**Required Configuration**:
```properties
management.endpoint.health.show-details=when-authorized
management.endpoint.health.show-components=when-authorized
```

### Metrics Export Configuration Namespace

**Impact**: Medium - Property rename

**Before**:
```properties
management.metrics.export.prometheus.enabled=true
management.metrics.export.graphite.host=localhost
```

**After**:
```properties
management.prometheus.metrics.export.enabled=true
management.graphite.metrics.export.host=localhost
```

**Migration Action**: Move format name (prometheus, graphite, etc.) before `metrics.export`

## REST Client Changes

### RestTemplate Deprecation Direction

**Impact**: Medium - Consider migration to RestClient

**Change**: While not removed, Spring Boot 4.0 encourages migration to `RestClient` or `WebClient`

**New Pattern (RestClient)**:
```java
@Bean
public RestClient restClient(RestClient.Builder builder) {
    return builder
        .baseUrl("https://api.example.com")
        .defaultHeader("Accept", "application/json")
        .build();
}

// Usage
public MyData getData(String id) {
    return restClient.get()
        .uri("/data/{id}", id)
        .retrieve()
        .body(MyData.class);
}
```

**Benefits**:
- Fluent API similar to WebClient
- Synchronous (easier migration from RestTemplate)
- Better integration with Spring Boot 4.0

## Jakarta EE 10+ Requirement

### All javax.* to jakarta.*

**Impact**: Should already be done in 3.x, but verify

**Change**: Spring Boot 4.0 requires Jakarta EE 10+

**Migration Action**: Ensure no `javax.*` imports remain (except possibly some annotations)

**Verify**:
```bash
grep -r "import javax\." --include="*.java" src/ | grep -v "annotation" | wc -l
# Should return 0
```

## Dependency Changes

### Removed Auto-configurations

**Impact**: Medium - May need explicit configuration

Some auto-configurations have been removed or relocated. Check release notes for specific cases.

### Third-party Library Updates

**Impact**: Variable - Depends on libraries used

Major library updates included in Spring Boot 4.0:
- Hibernate 7.x
- Spring Security 7.x
- Micrometer 1.14.x
- Jackson 2.18.x (or consider Jackson 3.x migration separately)

## Testing Changes

### JUnit 5 Requirement

**Impact**: Low - Most projects already using JUnit 5

**Verify**: All tests use JUnit 5 annotations:
```java
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
// NOT org.junit.Test (JUnit 4)
```

### MockMvc Changes

**Impact**: Low - Minor API adjustments

Most MockMvc code continues to work, but some deprecated methods may be removed.

## Configuration Properties

### Changed Property Keys

| Old Property (3.5.x) | New Property (4.0.x) | Impact |
|---------------------|---------------------|--------|
| `spring.redis.repositories.enabled` | `spring.data.redis.repositories.enabled` | Low |
| `management.metrics.export.{format}.*` | `management.{format}.metrics.export.*` | Medium |
| `spring.jpa.hibernate.use-new-id-generator-mappings` | (removed) | Low |

### Removed Properties

- `spring.jpa.hibernate.use-new-id-generator-mappings` - No longer needed
- `spring.jpa.properties.hibernate.id.new_generator_mappings` - No longer needed

## Build Configuration Changes

### Maven Plugin Versions

**Impact**: Low - Ensure compatibility

Recommended minimum versions:
- `maven-surefire-plugin`: 3.5.2+
- `maven-failsafe-plugin`: 3.5.2+
- `maven-compiler-plugin`: 3.13.0+

### Gradle Plugin Versions

**Impact**: Low - Ensure compatibility

Update Gradle wrapper and plugins:
- Gradle: 8.5+
- Spring Boot Gradle Plugin: 4.0.x
- Spring Dependency Management Plugin: 1.1.7+

## Behavioral Changes

### Default Behavior Changes

1. **Health Endpoint**: No longer shows details by default (security)
2. **Metrics**: Some metric names may have changed
3. **Logging**: Default logging patterns may differ slightly
4. **Error Handling**: Error response formats may be slightly different

### Performance Considerations

1. **Hibernate 7**: Different query execution plans possible
2. **Connection Pooling**: HikariCP behavior may differ
3. **Caching**: EhCache or other caching behavior may change

## Deprecation Warnings

### Address These in Spring Boot 4.0

Common deprecations to address:
1. Spring Security's old DSL style (use lambda DSL)
2. Old RestTemplate patterns (consider RestClient)
3. Deprecated Hibernate APIs
4. Old actuator endpoint paths

## Validation Commands

### Find Deprecated API Usage

```bash
# Spring Security old patterns
grep -r "WebSecurityConfigurerAdapter" --include="*.java" .
grep -r "antMatchers" --include="*.java" .
grep -r "mvcMatchers" --include="*.java" .

# Old JPA properties
grep -r "use-new-id-generator-mappings" src/main/resources/

# Old Redis properties
grep -r "spring.redis.repositories.enabled" src/main/resources/

# Old metrics properties
grep -r "management.metrics.export" src/main/resources/

# javax.* imports (should be jakarta.*)
grep -r "import javax\." --include="*.java" src/ | grep -v "annotation"
```

### Verify Java Version

```bash
cat .java-version
java -version
grep "<java.version>" pom.xml
```

## Quick Reference: Common Migration Tasks

1. ✅ Update Java to 21
2. ✅ Update Spring Boot parent to 4.0.x
3. ✅ Update mobile.de BOM to 4.0.x
4. ✅ Remove `WebSecurityConfigurerAdapter`
5. ✅ Replace `antMatchers()` with `requestMatchers()`
6. ✅ Update configuration properties (redis, metrics)
7. ✅ Remove deprecated JPA properties
8. ✅ Add health endpoint detail configuration
9. ✅ Update Maven/Gradle plugin versions
10. ✅ Test thoroughly (especially database and security)

## Additional Resources

- [Spring Boot 4.0 Release Notes](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-4.0-Release-Notes)
- [Spring Boot 4.0 Migration Guide](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-4.0-Migration-Guide)
- [Spring Security 7.0 Migration](https://docs.spring.io/spring-security/reference/migration-7/index.html)
- [Hibernate 7 Migration Guide](https://hibernate.org/orm/releases/7.0/)
