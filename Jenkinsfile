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

    stage('Configure AWS/EKS Access') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
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

    stage('Install AWS Load Balancer Controller') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws_credentials',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sh """
            helm repo add eks https://aws.github.io/eks-charts
            helm repo update
            helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
              -n kube-system \
              --set clusterName=${EKS_CLUSTER_NAME} \
              --set serviceAccount.create=false \
              --set serviceAccount.name=aws-load-balancer-controller
          """
        }
      }
    }

    stage('Deploy Application to EKS') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws_credentials',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sh """
            kubectl apply -f postgres-deployment.yaml
            kubectl apply -f backend-deployment.yaml
            kubectl apply -f frontend-deployment.yaml
            kubectl apply -f alb-ingress.yaml
          """
        }
      }
    }

    stage('Verify Deployment') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws_credentials',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sh """
            kubectl get pods -o wide
            kubectl get svc
          """
        }
      }
    }

    stage('Wait for ALB Provisioning') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws_credentials',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sh """
            echo "Waiting for ALB to become available..."
            timeout 180 bash -c 'while [[ -z $(kubectl get ingress app-ingress -o jsonpath="{.status.loadBalancer.ingress[0].hostname}") ]]; do sleep 10; done'
          """
        }
      }
    }
  }

  post {
    always {
      withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws_credentials',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
      ]]) {
        script {
          def ALB_HOST = sh(
            script: "kubectl get ingress app-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'",
            returnStdout: true
          ).trim()
          echo "🚀 Application URL: http://${ALB_HOST}"
          cleanWs()
        }
      }
    }
  }
}