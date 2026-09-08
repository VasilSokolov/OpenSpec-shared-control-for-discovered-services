# Reactive WebFlux: Complete Migration Example

Complete before/after `pom.xml` for a reactive WebFlux application (based on notification-inbound-service).

## Before (Spring Boot 3.5.3)

```xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.5.3</version>
</parent>

<properties>
    <java.version>17</java.version>
</properties>

<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>de.mobile.spring.boot.starter</groupId>
            <artifactId>mobile-spring-boot-starter-bom</artifactId>
            <version>3.5.3</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>

<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-webflux</artifactId>
    </dependency>
    <dependency>
        <groupId>de.mobile.spring.boot.starter</groupId>
        <artifactId>mobile-log4j2-webflux-spring-boot-starter</artifactId>
    </dependency>
    <dependency>
        <groupId>de.mobile.spring.boot.starter</groupId>
        <artifactId>mobile-metrics-webflux-spring-boot-starter</artifactId>
    </dependency>
    <dependency>
        <groupId>io.projectreactor</groupId>
        <artifactId>reactor-core-micrometer</artifactId>
        <version>1.2.12</version>
    </dependency>

    <!-- Test dependencies -->
    <dependency>
        <groupId>de.mobile.spring.boot.starter</groupId>
        <artifactId>mobile-logback-spring-boot-starter</artifactId>
    </dependency>
</dependencies>
```

## After (Spring Boot 4.0.x)

```xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>4.0.6</version>
</parent>

<properties>
    <java.version>21</java.version>
</properties>

<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>de.mobile.spring.boot.starter</groupId>
            <artifactId>mobile-spring-boot-starter-bom</artifactId>
            <version>4.0.5</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>

<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-webflux</artifactId>
    </dependency>
    <!-- CHANGED: mobile-log4j2-webflux-spring-boot-starter → mobile-log4j2-spring-boot-starter (BOM 4.0.5+) -->
    <dependency>
        <groupId>de.mobile.spring.boot.starter</groupId>
        <artifactId>mobile-log4j2-spring-boot-starter</artifactId>
    </dependency>
    <!-- CHANGED: webflux variant replaced by regular starter (BOM 4.0.5+) -->
    <dependency>
        <groupId>de.mobile.spring.boot.starter</groupId>
        <artifactId>mobile-metrics-spring-boot-starter</artifactId>
    </dependency>
    <!-- REMOVED: micrometer-registry-graphite — Graphite not supported in BOM 4.0.5+ -->
    <!-- UPDATED: reactor-core-micrometer version -->
    <dependency>
        <groupId>io.projectreactor</groupId>
        <artifactId>reactor-core-micrometer</artifactId>
        <version>1.2.18</version>
    </dependency>

    <!-- Test dependencies -->
    <dependency>
        <groupId>de.mobile.spring.boot.starter</groupId>
        <artifactId>mobile-test-spring-boot-starter</artifactId>
        <scope>test</scope>
    </dependency>
    <!-- REMOVED: mobile-logback-spring-boot-starter — use TestLogAppender instead -->
    <!-- ADDED: WebTestClient for reactive testing -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-webtestclient</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```

## Key Changes Summary

| What | Action | Reason |
|------|--------|--------|
| `java.version` | 17 → 21 | Spring Boot 4.0 requires Java 21 |
| Spring Boot parent | 3.5.3 → 4.0.6 | Target version |
| mobile.de BOM | 3.5.3 → 4.0.5 | Aligned with Spring Boot 4.0 |
| `mobile-log4j2-webflux-spring-boot-starter` | REPLACED → `mobile-log4j2-spring-boot-starter` | WebFlux variant removed in BOM 4.0.5 |
| `mobile-metrics-webflux-spring-boot-starter` | REPLACED → `mobile-metrics-spring-boot-starter` | WebFlux variant removed in BOM 4.0.5 |
| `micrometer-registry-graphite` | REMOVED | Graphite not supported in BOM 4.0.5+ |
| `reactor-core-micrometer` | 1.2.12 → 1.2.18 | Micrometer 2.x compatibility |
| `mobile-logback-spring-boot-starter` | REMOVED | Use `TestLogAppender` instead |
| `spring-boot-webtestclient` | ADDED | New test dependency for WebFlux |

See `reactive-webflux-test-logging.md` for the `TestLogAppender` implementation.
