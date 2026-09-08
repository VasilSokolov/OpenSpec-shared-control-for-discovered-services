# Spring Boot 4.0 Migration Patterns

## Pattern 1: Simple Servlet Web Application

**Before (Spring Boot 3.5.x)**:
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
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>de.mobile.spring.boot.starter</groupId>
        <artifactId>mobile-metrics-spring-boot-starter</artifactId>
    </dependency>
</dependencies>
```

**After (Spring Boot 4.0.x)**:
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
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>de.mobile.spring.boot.starter</groupId>
        <artifactId>mobile-metrics-spring-boot-starter</artifactId>
    </dependency>
    <!-- ADDED: HTTP client no longer transitive from metrics starter -->
    <dependency>
        <groupId>de.mobile.spring.boot.starter</groupId>
        <artifactId>mobile-http-client-spring-boot-starter</artifactId>
    </dependency>
</dependencies>
```

## Pattern 2: Reactive WebFlux Application

See `reactive-webflux-migration-example.md` for a complete before/after example.

**Key Reactive-Specific Changes**:
1. Replace `mobile-log4j2-webflux-spring-boot-starter` → `mobile-log4j2-spring-boot-starter`
2. Replace `mobile-metrics-webflux-spring-boot-starter` → `mobile-metrics-spring-boot-starter`
3. **Exception**: Keep `mobile-swagger-webflux-spring-boot-starter` unchanged
4. Remove `spring-boot-starter-web` with exclusions — replace with pure `spring-boot-starter-webflux`
5. Remove `micrometer-registry-graphite` — Graphite no longer supported in BOM 4.0.5+
6. For batch jobs needing metrics: add `metrics.prometheus.pushgateway.address` property
7. Update `reactor-core-micrometer` to 1.2.18+
8. Replace test file-logging with `TestLogAppender` pattern (see `reactive-webflux-test-logging.md`)
9. Add `spring-boot-webtestclient` to test dependencies

**Enforce pure reactive stack** with Maven Enforcer Plugin:
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-enforcer-plugin</artifactId>
    <executions>
        <execution>
            <id>ban-servlet-dependencies</id>
            <phase>test-compile</phase>
            <goals><goal>enforce</goal></goals>
            <configuration>
                <rules>
                    <bannedDependencies>
                        <excludes>
                            <exclude>javax.servlet:javax.servlet-api</exclude>
                            <exclude>jakarta.servlet:jakarta.servlet-api</exclude>
                            <exclude>org.apache.tomcat.embed:tomcat-embed-core</exclude>
                        </excludes>
                    </bannedDependencies>
                </rules>
            </configuration>
        </execution>
    </executions>
</plugin>
```

## Pattern 3: Application with Domain (MySQL)

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
    <!-- ADDED: Test container support (moved to test-jar in SB 4.0) -->
    <dependency>
        <groupId>de.mobile.spring.boot.starter</groupId>
        <artifactId>mobile-domain-spring-boot-starter</artifactId>
        <type>test-jar</type>
        <scope>test</scope>
    </dependency>
</dependencies>
```

**Gradle equivalent for test-jar**:
```groovy
testImplementation('de.mobile.spring.boot.starter:mobile-domain-spring-boot-starter') {
    artifact {
        classifier = 'tests'
        type = 'test-jar'
    }
}
```

## Build Configuration (All Patterns)

Add `<parameters>true</parameters>` to the compiler plugin in all projects:

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-compiler-plugin</artifactId>
    <configuration>
        <parameters>true</parameters>
    </configuration>
</plugin>
```

This preserves method parameter names in bytecode, enabling Spring's parameter name discovery for `@RequestParam` and similar annotations without explicit names.
