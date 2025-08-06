FROM maven:3.8.3-openjdk-17 AS builder

WORKDIR /src

COPY . /src

RUN mvn clean install -DskipTests=true

# --- Stage 2 ------
FROM openjdk:17-jdk-slim

COPY --from=builder /src/target/*.jar /app/bankapp.jar

WORKDIR /app

EXPOSE 8080

CMD ["java", "-jar", "bankapp.jar"]
