# Spring Boot 4.0 Migration Checklist

## Standard Migration Checklist

- [ ] **Application Type Identification**
  - [ ] Determined if application is servlet-based or reactive (WebFlux)
  - [ ] If reactive, consulted `reactive-webflux-migration.md`

- [ ] **Java Version**
  - [ ] Updated `.java-version` to 21
  - [ ] Updated `<java.version>` in pom.xml to 21
  - [ ] Updated compiler plugin source/target to 21
  - [ ] Verified Java 21 installed locally

- [ ] **Spring Boot Version**
  - [ ] Updated parent POM to 4.0.x
  - [ ] Updated Gradle plugin to 4.0.x (if using Gradle)

- [ ] **mobile.de BOM Version**
  - [ ] Updated `mobile-spring-boot-starter-bom` to 4.0.x

- [ ] **Dependencies**
  - [ ] Added `mobile-http-client-spring-boot-starter` (if using WebClient/RestClient)
  - [ ] Added `mobile-domain-spring-boot-starter` test-jar (if using domain tests)
  - [ ] Removed deprecated dependencies

- [ ] **Code Changes**
  - [ ] Updated health package imports: `org.springframework.boot.actuate.health.*` → `org.springframework.boot.health.contributor.*`
  - [ ] Updated Spring Security configuration (removed `WebSecurityConfigurerAdapter`)
  - [ ] Changed `antMatchers()` to `requestMatchers()`
  - [ ] Verified all Jakarta EE imports (no `javax.*`)
  - [ ] Updated custom Hibernate code (if any)

- [ ] **Configuration**
  - [ ] Removed deprecated properties (`spring.jpa.hibernate.use-new-id-generator-mappings`, etc.)
  - [ ] Updated actuator configuration
  - [ ] Updated metrics export configuration namespace
  - [ ] Verified database configuration

- [ ] **Tests**
  - [ ] Updated test dependencies
  - [ ] All tests pass
  - [ ] Integration tests with containers work

- [ ] **Build Configuration**
  - [ ] Added `<parameters>true</parameters>` to `maven-compiler-plugin`
  - [ ] Build completes successfully

- [ ] **CI/CD**
  - [ ] Updated build pipeline to Java 21
  - [ ] Updated Docker base images to Java 21

- [ ] **Validation**
  - [ ] Application starts locally
  - [ ] Actuator endpoints accessible
  - [ ] Key features tested manually

## Additional Checklist for Reactive (WebFlux) Applications

- [ ] **Servlet Dependency Cleanup**
  - [ ] Removed `spring-boot-starter-web` (if present with exclusions)
  - [ ] Verified no servlet dependencies in `mvn dependency:tree`
  - [ ] Confirmed Netty (not Tomcat) starts in logs

- [ ] **Reactive Starter Replacement (BOM 4.0.5+)**
  - [ ] Replaced `mobile-log4j2-webflux-spring-boot-starter` → `mobile-log4j2-spring-boot-starter`
  - [ ] Replaced `mobile-metrics-webflux-spring-boot-starter` → `mobile-metrics-spring-boot-starter`
  - [ ] Verified `mobile-swagger-webflux-spring-boot-starter` left unchanged (not affected)

- [ ] **Reactive Logging Changes**
  - [ ] Removed `mobile-logback-spring-boot-starter` from test dependencies
  - [ ] Implemented `TestLogAppender` pattern (see `reactive-webflux-test-logging.md`)
  - [ ] Refactored tests that used file-based logging (`test.log`)
  - [ ] Removed `test.logdir` system property configuration

- [ ] **Metrics Stack**
  - [ ] Removed `micrometer-registry-graphite` dependency (Graphite not supported in BOM 4.0.5+)
  - [ ] Removed all `metrics.graphite.*` configuration properties
  - [ ] Removed `management.metrics.export.graphite.*` properties
  - [ ] If batch job / short-lived process: configured `metrics.prometheus.pushgateway.address`
  - [ ] Verified metrics endpoint returns expected data

- [ ] **Reactive Dependencies**
  - [ ] Updated `reactor-core-micrometer` to 1.2.18+
  - [ ] Added `spring-boot-webtestclient` to test dependencies
  - [ ] Added `mobile-http-client-spring-boot-starter` (if using WebClient/RestClient)

- [ ] **Jackson 3.0 Migration** (separate from Spring Boot migration)
  - [ ] Checked for Jackson 2.x imports: `grep -r "import com.fasterxml.jackson" src/`
  - [ ] If found, run separate `mob-jackson-upgrade` skill
  - [ ] Verified JSON serialization/deserialization works

- [ ] **Reactive Validation**
  - [ ] Verified reactive endpoints return correct data
  - [ ] Checked Reactor metrics in `/actuator/metrics`
  - [ ] Verified no blocking calls on reactive threads (use BlockHound if needed)
