FROM openjdk:11

#COPY target/java-hello-world.war /usr/src/app
#checksum error is regarding copying and adding project files to container folder we have to mention explicit path of container
#ADD target/helloworld-1.1.jar helloworld-1.1.jar

#COPY /var/lib/jenkins/workspace/devops_prject/target/java-hello-world.war /usr/src/app
EXPOSE 8000
ADD target/devops-integration.jar devops-integration.jar
ENTRYPOINT ["java","-jar","devops-integration.jar"]
