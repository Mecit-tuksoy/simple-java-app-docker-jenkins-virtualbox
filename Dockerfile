FROM openjdk:17-jdk-alpine
COPY target/my-app-1.0-SNAPSHOT.jar /myapp/app.jar
WORKDIR /myapp
CMD ["java", "-jar", "app.jar"]