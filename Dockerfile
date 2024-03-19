FROM openjdk:11
#WORKDIR /usr/src/app
#COPY target/java-hello-world.war /usr/src/app
#checksum error 
#ADD target/helloworld-1.1.jar helloworld-1.1.jar

#COPY /var/lib/jenkins/workspace/devops_prject/target/java-hello-world.war /usr/src/app
EXPOSE 8000
ADD target/devops-integration.jar devops-integration.jar
ENTRYPOINT ["java","-jar","/devops-integration.jar"]
#ENTRYPOINT ["java", "-jar", "/helloworld-1.1.jars"]
#CMD ["java", "-jar", "java-hello-world.war"]
