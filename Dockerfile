FROM openjdk:11
WORKDIR /usr/src/app
COPY .m2/repository/org/cloudifysource/examples/java-hello-world-webapp/1.0-SNAPSHOT/java-hello-world-webapp-1.0-SNAPSHOT.war .
EXPOSE 8000
CMD [ "java", "-jar", "java-hello-world.war "]