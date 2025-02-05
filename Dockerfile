# Build stage
FROM maven:3.9-eclipse-temurin-21 AS builder
WORKDIR /build
COPY pom.xml .
# Copy source files (layer splitting for better caching)
COPY src ./src
# Build application (keep the build layer lean)
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app
# Copy built artifact from builder stage (use explicit naming)
COPY --from=builder /build/target/*.jar ./app.jar
# Best practice to use non-root user
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser
# Standard Spring Boot port (change if your app uses different)
EXPOSE 8080
# Add JVM options for better container runtime behavior
CMD ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]