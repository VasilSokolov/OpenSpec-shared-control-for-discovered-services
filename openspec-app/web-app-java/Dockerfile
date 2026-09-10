# Build context is openspec-app/web-app-java/ (self-contained — no path deps).
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /build
# Cache dependencies first.
COPY pom.xml ./
RUN mvn -q -e -B dependency:go-offline
COPY src ./src
RUN mvn -q -e -B clean package -DskipTests

FROM eclipse-temurin:21-jre AS runtime
# The gate scripts shell out to bash and git (git-preflight.sh runs a fetch-only
# `git fetch`). bash ships in the base image; add git + certs.
RUN apt-get update \
    && apt-get install -y --no-install-recommends git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /build/target/opsx-web-0.1.0.jar /app/opsx-web.jar

# The control repository is mounted here at runtime.
ENV OPSX_CONTROL_ROOT=/workspace
# Bind all interfaces inside the container; the host maps the port to loopback only.
ENV SERVER_ADDRESS=0.0.0.0
WORKDIR /workspace
EXPOSE 8787
ENTRYPOINT ["java", "-jar", "/app/opsx-web.jar"]
