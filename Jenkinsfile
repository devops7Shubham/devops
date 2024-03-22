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
        stage("Kubernetes Configuration"){
            steps{
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: 'aws_credentials',accessKeyVariable: 'AWS_ACCESS_KEY_ID',secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    sh "aws eks update-kubeconfig --region ap-south-1 --name example"
                    }
                }
            }
        stage("Kubernetes Deployment"){
            steps{
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: 'aws_credentials',accessKeyVariable: 'AWS_ACCESS_KEY_ID',secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    sh "/root/bin/kubectl apply -f Deployment.yaml --validate=false"
                    }
                }
            }
    }
}
