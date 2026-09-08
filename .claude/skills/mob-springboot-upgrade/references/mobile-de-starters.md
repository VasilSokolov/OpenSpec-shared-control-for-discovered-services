# mobile.de Spring Boot Starters Reference

## Overview

This document provides detailed information about mobile.de's internal Spring Boot starter libraries located at:
`/Users/dennissobczak/Git/mobile-spring-boot-starter/`

## Version Compatibility

| Spring Boot Version | mobile.de Starter Version | Java Version |
|---------------------|---------------------------|--------------|
| 3.5.x               | 3.5.0 - 3.5.x             | 17+          |
| 4.0.x               | 4.0.0 - 4.0.x             | 21+          |

## Available Starters

### Web Application Starters

#### mobile-domain-spring-boot-starter
**Purpose**: MySQL database setup for mobile-domain library

**Key Dependencies**:
- `mobile-domain-hibernate6`
- `mobile-eps-hibernate6`
- `mysql-connector-j`
- `hibernate-jcache`
- `HikariCP`

**4.0 Migration Notes**:
- Test container moved to test-jar
- Must add test-jar dependency if tests use embedded MySQL
- Uses Hibernate 7 in Spring Boot 4.0

**Usage**:
```xml
<dependency>
    <groupId>de.mobile.spring.boot.starter</groupId>
    <artifactId>mobile-domain-spring-boot-starter</artifactId>
</dependency>

<!-- For tests using embedded MySQL -->
<dependency>
    <groupId>de.mobile.spring.boot.starter</groupId>
    <artifactId>mobile-domain-spring-boot-starter</artifactId>
    <type>test-jar</type>
    <scope>test</scope>
</dependency>
```

#### mobile-http-client-spring-boot-starter
**Purpose**: Automatic configuration for Spring's WebClient and RestClient with proxy support

**Key Features**:
- WebClient.Builder autoconfiguration
- RestClient.Builder autoconfiguration
- Proxy configuration support
- Connection pooling

**4.0 Migration Notes**:
- **CRITICAL**: No longer transitively included via metrics starters
- Must be explicitly added if using WebClient or RestClient
- Check for `@Autowired WebClient` or `@Autowired RestClient` in code

**Usage**:
```xml
<dependency>
    <groupId>de.mobile.spring.boot.starter</groupId>
    <artifactId>mobile-http-client-spring-boot-starter</artifactId>
</dependency>
```

**Detection**:
```bash
grep -r "@Autowired.*WebClient" --include="*.java" .
grep -r "WebClient\.Builder" --include="*.java" .
grep -r "@Autowired.*RestClient" --include="*.java" .
```

#### mobile-gcp-spring-boot-starter
**Purpose**: GCP authentication within mobile.de infrastructure

**Key Features**:
- GCP credential management
- Authentication autoconfiguration
- Integration with mobile.de GCP setup

**4.0 Migration Notes**: No specific changes

#### mobile-jobs-spring-boot-starter
**Purpose**: WebSocket jobs for use with websocket-job-client-node

**4.0 Migration Notes**: No specific changes

#### mobile-test-spring-boot-starter
**Purpose**: Utilities for implementing integration tests

**Key Features**:
- Test utilities
- Integration test support
- Mobile.de-specific test helpers

**4.0 Migration Notes**: No specific changes

#### mobile-embedmongo-spring-boot-starter
**Purpose**: Download embedded MongoDB for integration testing

**Key Dependencies**:
- `de.flapdoodle.embed.mongo.spring3x`

**4.0 Migration Notes**: Verify Flapdoodle version compatibility with Spring Boot 4.0

### Logging Starters

#### mobile-log4j2-spring-boot-starter
**Purpose**: Default logging configuration using Log4j 2.x for servlet applications

**Key Dependencies**:
- `logstash-log4j2`
- Log4j 2 core libraries

**4.0 Migration Notes**: No specific changes

**Usage**:
```xml
<dependency>
    <groupId>de.mobile.spring.boot.starter</groupId>
    <artifactId>mobile-log4j2-spring-boot-starter</artifactId>
</dependency>
```

#### mobile-log4j2-webflux-spring-boot-starter
**Purpose**: Default logging configuration using Log4j 2.x for reactive applications

**4.0 Migration Notes**: No specific changes

#### mobile-logback-spring-boot-starter
**Purpose**: Alternative logging starter using Logback

**Key Dependencies**:
- `logstash-logback`
- Logback core libraries

**4.0 Migration Notes**: No specific changes

### Metrics Starters

#### mobile-metrics-spring-boot-starter
**Purpose**: Metrics and health checks for servlet applications

**Key Features**:
- Micrometer metrics
- Health check endpoints
- Actuator integration

**4.0 Migration Notes**:
- **CRITICAL**: No longer includes `mobile-http-client-spring-boot-starter`
- Add HTTP client dependency explicitly if needed

**Usage**:
```xml
<dependency>
    <groupId>de.mobile.spring.boot.starter</groupId>
    <artifactId>mobile-metrics-spring-boot-starter</artifactId>
</dependency>
<!-- Add if using WebClient/RestClient -->
<dependency>
    <groupId>de.mobile.spring.boot.starter</groupId>
    <artifactId>mobile-http-client-spring-boot-starter</artifactId>
</dependency>
```

#### mobile-metrics-webflux-spring-boot-starter
**Purpose**: Metrics and health checks for reactive applications

**4.0 Migration Notes**:
- **CRITICAL**: No longer includes `mobile-http-client-spring-boot-starter`
- Add HTTP client dependency explicitly if needed

#### mobile-dropwizard-metrics-spring-boot-starter
**Purpose**: Legacy starter for Dropwizard metrics

**Status**: **DO NOT USE for new projects** (legacy support only)

**Key Dependencies**:
- Dropwizard Metrics libraries
- `metrics-jakarta-servlet`

**4.0 Migration Notes**:
- Consider migrating to Micrometer-based metrics starters
- If continuing to use, add HTTP client dependency explicitly

### Swagger/OpenAPI Starters

#### mobile-swagger-spring-boot-starter
**Purpose**: Swagger UI for servlet applications

**Key Dependencies**:
- springdoc-openapi
- swagger-ui

**4.0 Migration Notes**: No specific changes

**Usage**:
```xml
<dependency>
    <groupId>de.mobile.spring.boot.starter</groupId>
    <artifactId>mobile-swagger-spring-boot-starter</artifactId>
</dependency>
```

#### mobile-swagger-webflux-spring-boot-starter
**Purpose**: Swagger UI for reactive applications

**4.0 Migration Notes**: No specific changes

## BOM (Bill of Materials)

### mobile-spring-boot-starter-bom

**Purpose**: Centralized dependency management for all mobile.de starters

**Current Versions**:
- Spring Boot 3.5.x compatible: `3.5.3`
- Spring Boot 4.0.x compatible: `4.0.4`

**Usage**:
```xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>de.mobile.spring.boot.starter</groupId>
            <artifactId>mobile-spring-boot-starter-bom</artifactId>
            <version>4.0.4</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

**Key Managed Dependencies** (from parent POM):
- `springdoc.version`: 3.0.3
- `swagger-ui.version`: 5.31.0
- `mobile-logstash.version`: 2.6
- `dropwizard-metrics.version`: 4.2.38
- `testcontainers.version`: 2.0.3
- `mobile-domain-hibernate6`: 7.5
- `mobile-eps-hibernate6`: 7.5

## Module Structure

Each starter follows this structure:

```
mobile-{name}-spring-boot-starter/
├── src/
│   ├── main/
│   │   ├── java/
│   │   └── resources/
│   └── test/
│       ├── java/
│       └── resources/
└── pom.xml

mobile-{name}-spring-boot-autoconfigure/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── de/mobile/spring/boot/starter/{name}/
│   │   │       ├── {Name}AutoConfiguration.java
│   │   │       └── {Name}Properties.java
│   │   └── resources/
│   │       └── META-INF/
│   │           └── spring.factories (or spring/autoconfigure...)
│   └── test/
└── pom.xml
```

## Common Patterns

### Pattern 1: Servlet Web Application with Metrics
```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>de.mobile.spring.boot.starter</groupId>
        <artifactId>mobile-metrics-spring-boot-starter</artifactId>
    </dependency>
    <dependency>
        <groupId>de.mobile.spring.boot.starter</groupId>
        <artifactId>mobile-log4j2-spring-boot-starter</artifactId>
    </dependency>
    <dependency>
        <groupId>de.mobile.spring.boot.starter</groupId>
        <artifactId>mobile-swagger-spring-boot-starter</artifactId>
    </dependency>
    <!-- Spring Boot 4.0: Add HTTP client -->
    <dependency>
        <groupId>de.mobile.spring.boot.starter</groupId>
        <artifactId>mobile-http-client-spring-boot-starter</artifactId>
    </dependency>
</dependencies>
```

### Pattern 2: Reactive Web Application with Metrics
```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-webflux</artifactId>
    </dependency>
    <dependency>
        <groupId>de.mobile.spring.boot.starter</groupId>
        <artifactId>mobile-metrics-webflux-spring-boot-starter</artifactId>
    </dependency>
    <dependency>
        <groupId>de.mobile.spring.boot.starter</groupId>
        <artifactId>mobile-log4j2-webflux-spring-boot-starter</artifactId>
    </dependency>
    <dependency>
        <groupId>de.mobile.spring.boot.starter</groupId>
        <artifactId>mobile-swagger-webflux-spring-boot-starter</artifactId>
    </dependency>
    <!-- Spring Boot 4.0: Add HTTP client -->
    <dependency>
        <groupId>de.mobile.spring.boot.starter</groupId>
        <artifactId>mobile-http-client-spring-boot-starter</artifactId>
    </dependency>
</dependencies>
```

### Pattern 3: Application with Domain (MySQL)
```xml
<dependencies>
    <dependency>
        <groupId>de.mobile.spring.boot.starter</groupId>
        <artifactId>mobile-domain-spring-boot-starter</artifactId>
    </dependency>
    
    <!-- Test dependencies -->
    <dependency>
        <groupId>de.mobile.spring.boot.starter</groupId>
        <artifactId>mobile-test-spring-boot-starter</artifactId>
        <scope>test</scope>
    </dependency>
    <!-- Spring Boot 4.0: Add test-jar for embedded MySQL -->
    <dependency>
        <groupId>de.mobile.spring.boot.starter</groupId>
        <artifactId>mobile-domain-spring-boot-starter</artifactId>
        <type>test-jar</type>
        <scope>test</scope>
    </dependency>
</dependencies>
```

## Repository Information

**Internal Repository**: `https://repo.mobint.io/repository/mo-maven`

**Maven Configuration**:
```xml
<repositories>
    <repository>
        <id>repo.mobint.io</id>
        <url>https://repo.mobint.io/repository/mo-maven</url>
    </repository>
</repositories>
```

## Example Projects

mobile.de provides blueprint projects:
- [spring-boot-example](https://github.mpi-internal.com/mobile-de/spring-boot-example) - Servlet-based Maven
- [spring-boot-job-example](https://github.mpi-internal.com/mobile-de/spring-boot-job-example) - Standalone job Maven
- [spring-boot-reactive-example](https://github.mpi-internal.com/mobile-de/spring-boot-reactive-example) - WebFlux Maven
- [spring-boot-kotlin-example](https://github.mpi-internal.com/mobile-de/spring-boot-kotlin-example) - Kotlin Maven
- [spring-boot-gradle-example](https://github.mpi-internal.com/mobile-de/spring-boot-gradle-example) - Servlet-based Gradle

## Quick Reference Commands

### Find mobile.de starters in project
```bash
grep -r "de.mobile.spring.boot.starter" pom.xml
```

### Check for WebClient/RestClient usage
```bash
grep -r "@Autowired.*WebClient\|WebClient\.Builder" --include="*.java" .
grep -r "@Autowired.*RestClient\|RestClient\.Builder" --include="*.java" .
```

### Check for domain test container usage
```bash
grep -r "MySQLContainer\|@Testcontainers" --include="*.java" src/test/
```

### Verify mobile.de BOM version
```bash
grep -A 4 "mobile-spring-boot-starter-bom" pom.xml
```

## Support

For issues or questions about mobile.de starters:
- Consult the platform team
- Check MIGRATION_GUIDE.md in mobile-spring-boot-starter repo
- Review README.md in mobile-spring-boot-starter repo
- Check individual starter README files
