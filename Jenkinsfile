pipeline{
    agent any
    stages{
        stage("Git Checkout"){
            steps{
                checkout scmGit(branches: [[name: '*/main']], 
                extensions: [], 
                userRemoteConfigs: [[url: 'https://github.com/devops7Shubham/devops.git']])
            }
        }
        stage("Maven Build"){
            steps{
                sh 'mvn clean install'
            }
        }
        stage("Docker build"){
            steps{
                sh 'docker buildx build -t shubhamdevops/java_hello_world .'
            }
        }
        stage("Docker Push"){
            steps{
                withCredentials([usernamePassword(credentialsId: 'shubhamdevops', passwordVariable: 'docker_password', usernameVariable: 'docker_username')]){
                    sh "docker login -u ${docker_username} -p ${docker_password}"
                    sh 'docker push shubhamdevops/java_hello_world'
                }

            }
        }
    }
}
