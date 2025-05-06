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
    // ... [Keep all previous stages until 'Install AWS Load Balancer Controller']

    stage('Install AWS Load Balancer Controller') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws_credentials',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sh """
            # Force cleanup of previous installations
            helm uninstall aws-load-balancer-controller -n kube-system 2>/dev/null || true
            
            # Install with wait and timeout
            helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
              -n kube-system \
              --set clusterName=${EKS_CLUSTER_NAME} \
              --set serviceAccount.create=false \
              --set serviceAccount.name=aws-load-balancer-controller \
              --wait --timeout 5m
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
            # Apply core components first
            kubectl apply -f postgres-deployment.yaml
            kubectl apply -f backend-deployment.yaml
            kubectl apply -f frontend-deployment.yaml

            # Retry ingress creation with delay
            for i in {1..3}; do
              kubectl apply -f alb-ingress.yaml && break
              sleep 15
            done
          """
        }
      }
    }

    stage('Verify ALB Provisioning') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws_credentials',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sh """
            # Wait max 3 minutes for ALB
            timeout 180 bash -c 'while [[ -z $(kubectl get ingress app-ingress -o jsonpath="{.status.loadBalancer.ingress[0].hostname}" 2>/dev/null) ]]; do sleep 10; done'
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
            script: "kubectl get ingress app-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo 'alb-not-created'",
            returnStdout: true
          ).trim()
          echo "Application Status: ${ALB_HOST}"
          cleanWs()
        }
      }
    }
  }
}