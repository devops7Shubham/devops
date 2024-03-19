FROM openjdk:11
WORKDIR /usr/src/app
COPY /var/lib/jenkins/workspace/devops_prject/target/java-hello-world.war .
EXPOSE 8000
CMD [ "java", "-jar", "java-hello-world.war "]