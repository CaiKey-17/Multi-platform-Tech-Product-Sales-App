# -------------------------------------------------------
# 1) Build stage
# -------------------------------------------------------
FROM maven:3.8.5-openjdk-17-slim AS build

# Set working directory in the container
WORKDIR /app

# Copy everything from the current context (which is ./api) into /app
COPY . .

# Build the Spring Boot jar, skipping tests
RUN mvn clean package -DskipTests


# -------------------------------------------------------
# 2) Runtime stage
# -------------------------------------------------------
FROM openjdk:17-jdk-slim

# Set working directory in the runtime container
WORKDIR /app

# Copy the jar from the build stage
COPY --from=build /app/target/*.jar api.jar

# Expose Eureka default port
EXPOSE 8761

# Start the application
ENTRYPOINT ["java", "-jar", "api.jar"]
