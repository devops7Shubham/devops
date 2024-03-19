FROM openjdk:11
#WORKDIR /usr/src/app
#COPY target/java-hello-world.war /usr/src/app
#checksum error 
ADD target/java-hello-world.war java-hello-world.war

#COPY /var/lib/jenkins/workspace/devops_prject/target/java-hello-world.war /usr/src/app
EXPOSE 8000
ENTRYPOINT ["java", "-jar", "java-hello-world.war"]
#CMD ["java", "-jar", "java-hello-world.war"]
