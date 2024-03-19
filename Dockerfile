FROM openjdk:11
#WORKDIR /usr/src/app
#COPY target/java-hello-world.war /usr/src/app
#checksum error 
ADD target/helloworld-1.1.jar helloworld-1.1.jar

#COPY /var/lib/jenkins/workspace/devops_prject/target/java-hello-world.war /usr/src/app
EXPOSE 8000
ENTRYPOINT ["java", "-jar", "/helloworld-1.1.jar"]
#CMD ["java", "-jar", "java-hello-world.war"]
