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
        stage("Build"){
            steps{
                sh 'mvn clean install'
            }
        }
    }
}
