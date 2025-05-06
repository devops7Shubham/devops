pipeline {
  agent any

  environment {
    DOCKERHUB_NAMESPACE = 'shubhamdevops'
    BACKEND_IMAGE       = "${DOCKERHUB_NAMESPACE}/backend-app:latest"
    FRONTEND_IMAGE      = "${DOCKERHUB_NAMESPACE}/frontend-app:latest"
    EKS_CLUSTER_NAME    = 'simple-eks'
    AWS_REGION          = 'us-east-1'
  }

  stages {
    stage('Git Checkout') {
      steps {
        checkout scmGit(
          branches: [[name: '*/demo']],
          extensions: [],
          userRemoteConfigs: [[
            url: 'https://github.com/devops7Shubham/devops.git'
          ]]
        )
      }
    }

    stage('Build Docker Images') {
      steps {
        sh "docker buildx build --load -t ${BACKEND_IMAGE} ./backend"
        sh "docker buildx build --load -t ${FRONTEND_IMAGE} ./frontend"
      }
    }

    stage('Push to Docker Hub') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'shubhamdevops',
          usernameVariable: 'DOCKER_USER',
          passwordVariable: 'DOCKER_PASS'
        )]) {
          sh '''
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            docker push ${BACKEND_IMAGE}
            docker push ${FRONTEND_IMAGE}
          '''
        }
      }
    }

    stage('Kubernetes Configuration') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws_credentials',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sh """
            aws eks update-kubeconfig \
              --region ${AWS_REGION} \
              --name ${EKS_CLUSTER_NAME}
          """
        }
      }
    }

    stage('Verify EKS Nodes') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws_credentials',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sh "kubectl get nodes -o wide"
        }
      }
    }
 stage('Kubernetes Deployment') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws_credentials',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sh '''
            export KUBECONFIG=$KUBECONFIG
            kubectl apply -f k8s/postgres-deployment.yaml --validate=false
            kubectl apply -f k8s/backend-deployment.yaml  --validate=false
            kubectl apply -f k8s/frontend-deployment.yaml --validate=false
            kubectl apply -f k8s/ingress.yaml             --validate=false
          '''
        }
      }
    }

    stage('Wait for Ingress Ready') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws_credentials',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sh '''
            export KUBECONFIG=$KUBECONFIG
            echo "Waiting for Ingress to be ready..."
            kubectl wait --for=jsonpath='{.status.loadBalancer.ingress[0]}' \
              ingress/my-app-ingress --timeout=180s
          '''
        }
      }
    }

    stage('Get Application URL') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws_credentials',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          script {
            def host = sh(
              script: "kubectl get ingress my-app-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'",
              returnStdout: true
            ).trim()
            if (!host) {
              host = sh(
                script: "kubectl get ingress my-app-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}'",
                returnStdout: true
              ).trim()
            }
            echo "🎉 Your application is available at: http://${host}/"
          }
        }
      }
    }
  }

  post {
    always {
      cleanWs()   // ensure workspace is clean for next run
    }
  }
}